if not AI then
    AI = class({})
end

require("ai/controller")
require("ai/upgrader")
require("ai/debug")
require("ai/garage_ai")
require("ai/super_unit_ai")

function AI:Init()
    AI.Players = {}
    AI.BotIDs = {}
    AI.Logs = {}
    AI.PrintLevels = {}

    AI.PrintLevels["File"] = false
    AI.PrintLevels["Resource"] = false
    AI.PrintLevels["Upgrades"] = false
    AI.PrintLevels["Movement"] = false

    AI.Settings = LoadKeyValues("scripts/kv/ai_settings.kv")
    AI.ThinkTimes = {
        ["easy"] = {["Upgrade"]=30,["Attack"]=10},
        ["normal"] = {["Upgrade"]=15,["Attack"]=10},
        ["hard"] = {["Upgrade"]=1,["Attack"]=1},
    }
    -- Default normal
    AI.ATTACK_THINK_TIME = 15
    AI.UPGRADE_THINK_TIME = 15

    Convars:RegisterCommand("aidebug_upgrades", function(...) AI:DebugUpgrades(...) end, "", 0)
end

PLAYER_CREATED_HEROES = {}
function AI:SpawnBots()
    local player_count = PlayerResource:GetPlayerCount()
    -- Limit the bots to available hero count
    local bots_required = math.min(PMP_MAX_PLAYERS - player_count, PMP_ENABLED_HERO_COUNT - player_count) - 2
    local added_bots = 0

    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, bots_required + PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS) )
    for playerID=player_count,player_count+bots_required-1 do
        Timers((playerID-1)*5, function()
            AI:print("AddBot "..playerID)
            Tutorial:AddBot(RACES[RandomInt(1,#RACES)],'','',false)

            Timers(2, function()
                if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:IsFakeClient(playerID) then
                    if PlayerResource:GetSelectedHeroEntity(playerID) then
                        AI:InitFakePlayer(playerID)
                    else
                        local player = PlayerResource:GetPlayer(playerID)
                        if player then
                            if not PLAYER_CREATED_HEROES[playerID] then
                                CreateHeroForPlayer(RACES[RandomInt(1,#RACES)], player)
                                PLAYER_CREATED_HEROES[playerID] = true
                                AI:print("CreateHeroForPlayer "..playerID)
                            end
                        end
                        return 0.5
                    end
                end
            end)
        end)
    end
end

function AI:InitFakePlayer(playerID, hero)
    local hero = PlayerResource:GetSelectedHeroEntity(playerID) or hero
    if hero then
        if hero.initialized then
            return
        end

        hero.initialized = true
        local teamNumber = hero:GetTeamNumber()
        local color = PMP:ColorForTeam( teamNumber )
        local race = GetRace(hero)

        print("InitFakePlayer "..playerID.." "..race.." on team "..teamNumber)

        AI:InitPlayerLog(playerID)

        local build = LoadKeyValues("scripts/kv/ai_settings.kv")
        table.insert(AI.BotIDs, playerID)
        AI.Players[playerID] = {}
        AI.Players[playerID].Build = build['Builds'][race] or build['Builds']['Generic']
        AI.Players[playerID].Build.next_gold_upgrade = 1
        AI.Players[playerID].Build.next_lumber_upgrade = 1

        Timers(1, function()
            GarageAI:Start(playerID, GetPlayerCityCenter(playerID))
            self:StartThink(playerID, hero)
        end)
    else
        AI:print("Tried to initialize a player AI without a hero or teamnumber")
        print(playerID, hero, teamNumber)
    end
end

function AI:SetBotDifficulty(option)
    self.ATTACK_THINK_TIME = AI.ThinkTimes[option]["Attack"]
    self.UPGRADE_THINK_TIME = AI.ThinkTimes[option]["Upgrade"]
end

function AI:GetBotDifficulty()
    return GameRules.BotDifficulty
end

function AI:StartThink(playerID, hero)
    Timers(function()
        if not hero.lost then
            AI:ControlUnits(playerID)
            return self.ATTACK_THINK_TIME
        end
    end)

    Timers(function()
        local state = GameRules:State_Get()
        if not hero.lost then
            AI:UseResources(playerID)
            return self.UPGRADE_THINK_TIME
        end
    end)  
end

function AI:print(str, level)
    if level then
        if AI:ActiveLog(level) ~= false then
            print("[AI "..level.."] ".. str)
        end
    else
        print("[AI] ".. str)
    end
end

if not AI.Players then AI:Init() end