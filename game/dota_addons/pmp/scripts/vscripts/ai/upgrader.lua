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
    if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then return end
    
    self:print("UseResources "..GetGold(playerID).." gold & "..GetLumber(playerID).." lumber","Resource")

    if IsValidAlive(shop) and IsValidAlive(garage) then
        local nextGold = self:GetNextGoldUpgrade(playerID)
        local nextLumber = self:GetNextLumberUpgrade(playerID)

        if nextGold then
            self:print("Next Gold upgrade: "..nextGold,"Resource")
            local unit = shop
            local upgrade_ability = unit:FindAbilityByName(nextGold) or unit:FindItemByName(nextGold)
            if not upgrade_ability then
                unit = garage
                upgrade_ability = unit:FindAbilityByName(nextGold)
            end

            if not upgrade_ability then
                AI:Log(playerID, "Error, can't find upgrade ability "..nextGold)
                local upgrades = PMP:GetUpgradeList(playerID)
                for k,v in pairs(upgrades) do
                    AI:Log(playerID, "    " ..k..": "..v)
                end
            elseif upgrade_ability:CanBeAffordedByPlayer(playerID) then
                
                AI:Log(playerID, "Used "..nextGold)
                self:print("SUCCESS: Upgraded "..nextGold,"Resource")
                local needed = upgrade_ability:GetCustomGoldCost()
                ExecuteOrderFromTable({UnitIndex = unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET, AbilityIndex = upgrade_ability:GetEntityIndex(), Queue = 1}) 
                self:IncrementNextGoldUpgrade(playerID)
            end
        else
            local upgrade_ability
            local unit
            local upgrade_health = shop:FindAbilityByName("upgrade_health")
            local upgrade_food_limit = garage:FindAbilityByName("upgrade_food_limit")
            
            if upgrade_food_limit and GetFoodUsed(playerID) == GetFoodLimit(playerID) then
                upgrade_ability = upgrade_food_limit
                unit = garage
            elseif upgrade_health then
                upgrade_ability = upgrade_health
                unit = shop
            end

            -- Only Hard bots keep using their gold after running out of upgrades
            if upgrade_ability and self:GetBotDifficulty() == "hard" then
                if upgrade_ability:CanBeAffordedByPlayer(playerID) then
                    self:print(GetBotName(playerID).." ran out of gold upgrades and choose to upgrade "..upgrade_ability:GetAbilityName())
                    AI:Log(playerID, "Used "..upgrade_ability:GetAbilityName())
                    ExecuteOrderFromTable({UnitIndex = unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET, AbilityIndex = upgrade_ability:GetEntityIndex(), Queue = 1}) 
                end
            end
        end

        if nextLumber then
            local build = self:GetBuild(playerID)
            local level = build.next_lumber_upgrade
            self:print("Current Lumber upgrade of "..playerID..": "..nextLumber.."("..level..")","Resource")
            
            local upgrade_ability = shop:FindAbilityByName(nextLumber)
            if not upgrade_ability then
                AI:Log(playerID, "Error, can't find upgrade ability "..nextLumber)
                local upgrades = PMP:GetUpgradeList(playerID)
                for k,v in pairs(upgrades) do
                    if tonumber(v) > 0 then
                        AI:Log(playerID,"    "..k.." "..v)
                    end
                end

            elseif upgrade_ability:CanBeAffordedByPlayer(playerID) then
                ExecuteOrderFromTable({UnitIndex = shop:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET, AbilityIndex = upgrade_ability:GetEntityIndex(), Queue = 1}) 
                AI:Log(playerID, "Used "..nextLumber.." - next : "..self:GetNextLumberUpgrade(playerID))
                self:IncrementNextLumberUpgrade(playerID)
            end
        end
    end
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
    return AI.Players[playerID].Build
end
