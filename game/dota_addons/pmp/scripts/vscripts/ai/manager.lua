if not AI then
    AI = class({})
end

require("ai/controller")
require("ai/upgrader")
require("ai/debug")

function AI:Init()
    AI.Players = {}
    AI.Logs = {}
    AI.PrintLevels = {}

    AI.PrintLevels["Resource"] = false
    AI.PrintLevels["Upgrades"] = true
    AI.PrintLevels["Movement"] = false

    AI.Settings = LoadKeyValues("scripts/kv/ai_settings.kv")
    AI_THINK_TIME = 1

    Convars:RegisterCommand("aidebug_upgrades", function(...) AI:DebugUpgrades(...) end, "", 0)
end

local races = {"npc_dota_hero_axe","npc_dota_hero_undying","npc_dota_hero_skeleton_king","npc_dota_hero_meepo","npc_dota_hero_dragon_knight",
               "npc_dota_hero_silencer","npc_dota_hero_treant",--[["npc_dota_hero_drow_ranger","npc_dota_hero_warlock"--]]}

function AI:SpawnBots()
    local player_count = PlayerResource:GetPlayerCount()
    local bots_required = PMP_MAX_PLAYERS - player_count

    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, bots_required + PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS) )
    for playerID=player_count,player_count+bots_required-1 do
        Timers:CreateTimer((playerID-1)*3, function()
            AI:print("AddBot "..playerID)
            Tutorial:AddBot(races[RandomInt(1,#races)],'','',false)

            Timers:CreateTimer(2, function()
                if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:IsFakeClient(playerID) then
                    if PlayerResource:GetSelectedHeroEntity(playerID) then
                        AI:InitFakePlayer(playerID)
                    else
                        local player = PlayerResource:GetPlayer(playerID)
                        if player then
                            CreateHeroForPlayer(races[RandomInt(1,#races)], player)
                            AI:print("CreateHeroForPlayer "..playerID)
                        end
                        return 0.1
                    end
                end
            end)
        end)
    end
end

function AI:InitFakePlayer(playerID)
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if hero then
        local teamNumber = hero:GetTeamNumber()
        local color = PMP:ColorForTeam( teamNumber )
        local race = GetRace(hero)

        print("InitFakePlayer "..playerID.." "..race.." on team "..teamNumber)

        AI:InitPlayerLog(playerID)

        local build = LoadKeyValues("scripts/kv/ai_settings.kv")
        AI.Players[playerID] = {}
        AI.Players[playerID].Build = build['Builds'][race] or build['Builds']['Generic']
        AI.Players[playerID].Build.next_gold_upgrade = 1
        AI.Players[playerID].Build.next_lumber_upgrade = 1

        Timers:CreateTimer(function()
            local state = GameRules:State_Get()
            if state >= DOTA_GAMERULES_STATE_PRE_GAME and state < DOTA_GAMERULES_STATE_POST_GAME then
                if not hero.lost then
                    self:Think(playerID)
                    return AI_THINK_TIME
                end
            end
            return AI_THINK_TIME
        end)
    else
        AI:print("Tried to initialize a player AI without a hero or teamnumber")
        print(playerID, hero, teamNumber)
    end
end

function AI:Think(playerID)
    AI:UseResources(playerID)
    AI:GroupUnits(playerID)
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