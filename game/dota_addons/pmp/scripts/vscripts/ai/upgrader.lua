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
