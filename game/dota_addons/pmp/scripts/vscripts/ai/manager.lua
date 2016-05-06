if not AI then
    AI = class({})
    require("ai/controller")
    require("ai/upgrader")
end

function AI:Init()
    AI.Players = {}
    AI.Log = {}
    AI.Log["Resource"] = false
    AI.Log["Movement"] = false
    AI.Settings = LoadKeyValues("scripts/kv/ai_settings.kv")
    AI_THINK_TIME = 0.5
end

local races = {"npc_dota_hero_axe","npc_dota_hero_undying","npc_dota_hero_skeleton_king","npc_dota_hero_meepo","npc_dota_hero_dragon_knight",
               "npc_dota_hero_silencer","npc_dota_hero_treant",--[["npc_dota_hero_drow_ranger","npc_dota_hero_warlock"--]]}

function AI:SpawnBots()
    local player_count = PlayerResource:GetPlayerCount()
    local bots_required = PMP_MAX_PLAYERS - player_count

    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, bots_required + PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS) )
    for playerID=player_count,PMP_MAX_PLAYERS-1 do
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
    local teamNumber = PlayerResource:GetTeam(playerID)
    for k,teamID in pairs(VALID_TEAMS) do
        local teamPlayerCount = PlayerResource:GetPlayerCountForTeam(teamID)
        if teamPlayerCount == 0 then
            print("InitFakePlayer "..playerID.." reassigned to team "..teamID)
            PlayerResource:SetCustomTeamAssignment(playerID, teamID)
            teamNumber = teamID
            break
        end
    end

    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    if hero and teamNumber then
        local color = PMP:ColorForTeam( teamNumber )
        local playerName = GetEnglishTranslation(hero:GetUnitName()).." Bot"

        print("InitFakePlayer "..playerID.." "..playerName.." on team "..teamNumber)

        self.Players[playerID] = {}
        self.Players[playerID].Build = self.Settings['Builds']['Generic']
        self.Players[playerID].Build.next_gold_upgrade = 1
        self.Players[playerID].Build.next_lumber_upgrade = 1

        hero:SetTeam(teamNumber)
        hero:SetPlayerID(playerID)
        hero:SetOwner(PlayerResource:GetPlayer(playerID))
        local units = GetPlayerUnits(playerID)
        if not units then return 0.1 end --try again

        for k,v in pairs(units) do
            v:SetTeam(teamNumber)
            v:SetOwner(hero)
        end

        local buildings = GetPlayerBuildings(playerID)
        if not buildings then return 0.1 end --try again
        for k,v in pairs(buildings) do
            v:SetTeam(teamNumber)
            v:SetOwner(hero)
        end

        PlayerResource:SetCustomPlayerColor( playerID, color[1], color[2], color[3] )
        hero.garage:SetCustomHealthLabel( playerName, color[1], color[2], color[3])  -- Add a label on the base

        SetGold(playerID, INITIAL_GOLD+20)
        SetLumber(playerID, INITIAL_LUMBER+20)

        table.insert(GameRules.StillInGame, hero)

        Timers:CreateTimer(function()
            if GameRules:State_Get() >= DOTA_GAMERULES_STATE_PRE_GAME then
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

    Timers:CreateTimer(30, function()
        if not PlayerResource:GetSelectedHeroEntity(playerID).lost then
            AI:AcquireWeakEnemy(playerID)
            return 30
        end
    end)
end

function AI:ActiveLog( level )
    return AI.Log[level]
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