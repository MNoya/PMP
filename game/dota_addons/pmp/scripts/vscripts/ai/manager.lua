if not AI then
    AI = class({})
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
        Timers:CreateTimer(playerID*2, function()
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
        if not PlayerResource:GetSelectedHeroEntity(targetEnemy).lost then
            AI:AcquireWeakEnemy(playerID)
            return 30
        end
    end)
end

function AI:GroupUnits(playerID)
    local units = GetPlayerUnits(playerID)

    -- First, make sure the units are in a group
    if not AI:AreUnitsGrouped(playerID, units) then
        local pos = GetPlayerCityCenter(playerID).rally_point
        AI:AcquireWeakEnemy(playerID)
        AI:MoveUnitsInFormation(playerID, units, pos)

    else --Attack together
        local pos = GetPlayerCityCenter(playerID).rally_point
        local targetEnemy = AI:GetBotAttackTarget(playerID)
        if not targetEnemy or PlayerResource:GetSelectedHeroEntity(targetEnemy).lost then
            AI:AcquireWeakEnemy(playerID)
            return
        else
            local target = GetPlayerCityCenter( targetEnemy )
            if IsValidAlive(target) then
                pos = target:GetAbsOrigin()
            else
                AI:AcquireWeakEnemy(playerID)
                return
            end
        end

        AI:MoveUnitsInFormation(playerID, units, pos)
    end
end

function AI:MoveUnitAggresive(unit, target_pos)
    if IsInToolsMode() or AI:ActiveLog("Movement") then
        local color = PMP:ColorForTeam(unit:GetTeamNumber())
        DebugDrawLine(unit:GetAbsOrigin(), target_pos, color[1], color[2], color[3], true, 5)
        DebugDrawCircle(target_pos, Vector(color[1], color[2], color[3]), 255, 10, true, 5)
    end
    unit:MoveToPositionAggressive(target_pos)
end

function AI:MoveUnitsInFormation(playerID, units, target_pos)
    local gridPoints = GetGridAroundPoint(#units, target_pos)
    for k,unit in pairs(units) do
        if IsValidAlive(unit) then
            if unit:IsIdle() then
                AI:MoveUnitAggresive(unit, gridPoints[tonumber(k)])
            end
        end
    end
end

--sorta lazy check
function AI:AreUnitsGrouped(playerID, units)
    return GetFoodUsed(playerID) >= GetFoodLimit(playerID)*0.7
end

function AI:GetBotAttackTarget(playerID)
    return AI.Players[playerID].AttackTarget
end

function AI:SetBotAttackTarget(playerID, enemyPlayerID)
    AI.Players[playerID].AttackTarget = enemyPlayerID
end

function AI:OnLevelUp(playerID)
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local build = AI:GetBuild(playerID)
    local primary = build['Levels'].primary
    local secondary = build['Levels'].secondary

    local ability1 = hero:FindAbilityByName(primary)
    if primary then hero:UpgradeAbility(ability1) end

    local ability2 = hero:FindAbilityByName(secondary)
    if secondary then hero:UpgradeAbility(ability2) end
end

function AI:UseResources(playerID)
    local shop = GetPlayerShop(playerID)
    local garage = GetPlayerCityCenter(playerID)
    
    local nextGold = self:GetNextGoldUpgrade(playerID)
    local nextLumber = self:GetNextLumberUpgrade(playerID)

    self:print("UseResources "..GetGold(playerID).." gold & "..GetLumber(playerID).." lumber","Resource")

    if IsValidAlive(shop) and IsValidAlive(garage) then
        if nextGold then
            self:print("Next Gold upgrade: "..nextGold,"Resource")
            if self:TryUpgrade(playerID, shop, nextGold) or self:TryUpgrade(playerID, garage, nextGold) then
                self:print("SUCCESS: Upgraded "..nextGold,"Resource")
                self:IncrementNextGoldUpgrade(playerID)
            end
        end

        if nextLumber then
            self:print("Next Lumber upgrade: "..nextLumber,"Resource")
            if self:TryUpgrade(playerID, shop, nextLumber) then
                self:print("SUCCESS: Upgraded "..nextLumber,"Resource")
                self:IncrementNextLumberUpgrade(playerID)
            end
        end
    end
end

function AI:TryUpgrade(playerID, unit, upgrade_name) 
    local upgrade_ability = unit:FindAbilityByName(upgrade_name) or unit:FindItemByName(upgrade_name)
    if upgrade_ability then
        if upgrade_ability:CanBeAffordedByPlayer(playerID) then
            self:print("Casting "..upgrade_name.." on "..unit:GetUnitName(),"Resource")
            unit:CastAbilityNoTarget(upgrade_ability, playerID)
            return true
        end
    end
    return false
end

function AI:IncrementNextGoldUpgrade(playerID)
    local build = self:GetBuild(playerID)
    build.next_gold_upgrade = build.next_gold_upgrade + 1
end

function AI:IncrementNextLumberUpgrade(playerID)
    local build = self:GetBuild(playerID)
    build.next_lumber_upgrade = build.next_lumber_upgrade + 1
end

function AI:GetNextGoldUpgrade(playerID)
    local build = self:GetBuild(playerID)
    local level = build.next_gold_upgrade
    return build['Gold'][tostring(level)]
end

function AI:GetNextLumberUpgrade(playerID)
    local build = self:GetBuild(playerID)
    local level = build.next_lumber_upgrade
    return build['Lumber'][tostring(level)]
end

function AI:GetBuild( playerID )
    return self.Players[playerID].Build
end

function AI:AcquireWeakEnemy(playerID)
    local targetEnemy
    local teamNumber = PlayerResource:GetTeam(playerID)
    local origin = GetPlayerCityCenter(playerID):GetAbsOrigin()
    local targetDistance = 99999
    local targetKills = 99999
    local myKills = PlayerResource:GetKills(playerID)

    for _,hero in pairs(GameRules.StillInGame) do
        local pID = hero:GetPlayerID()
        if PlayerResource:GetTeam(pID) ~= teamNumber then
            local kills = PlayerResource:GetKills(pID)
            local distance = (origin - hero:GetAbsOrigin()):Length2D()

            --[[Distance to nearby base is ~2.5k, ~3.6k in diagonal, ~5.7k to the other side, ~7.2k on cross diagonal
            Logic should be:
                If there is a target reachable on the side (first <3k, then <4k) attack the best of those
                If there isn't, find on the whole map
            --]]
            if distance < 3000 then
                if kills <= targetKills then
                    targetEnemy = pID
                    targetDistance = distance
                    targetKills = kills
                end

            elseif distance < 4000 and targetDistance >= 3000 then
                if kills <= targetKills then
                    targetEnemy = pID
                    targetDistance = distance
                    targetKills = kills
                end

            else --Only attack an enemy past 4k if there is no one close to attack
                if kills <= targetKills then
                    targetEnemy = pID
                    targetDistance = distance
                    targetKills = kills
                end              
            end
        end
    end
    
    AI:print("SetBotAttackTarget "..playerID..": ".. targetEnemy.." with "..targetKills.." kills at "..targetDistance.." distance","AcquireWeakEnemy")
    AI:SetBotAttackTarget(playerID, targetEnemy)
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

function IterateAbilities( unit, callback )
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability then callback(ability) end
    end
end

if not AI.Players then AI:Init() end