function SpawnUnit( event )
    local caster = event.caster
    local owner = caster:GetOwner()
    local player = caster:GetPlayerOwner()
    local playerID = player:GetPlayerID()
    local hero = player:GetAssignedHero()
    local ability = event.ability
    local unit_name = event.UnitName
    local position = caster:GetAbsOrigin()
    local teamID = caster:GetTeam()

    local food_cost = GetFoodCost(unit_name)
    local numSpawns = GetSpawnRate(playerID)

    -- Don't spawn more than 1 leader
    if string.match(unit_name,"_leader") then
        numSpawns = 1
    end

    for i=1,numSpawns do

        if not PlayerHasEnoughFood(playerID, food_cost) then
            return
        else
            ModifyFoodUsed(playerID, food_cost)
        end

        local unit = CreateUnitByName(unit_name, position, true, owner, owner, caster:GetTeamNumber())
        unit:SetOwner(hero)
        unit:SetControllableByPlayer(playerID, true)
        FindClearSpaceForUnit(unit, position, true)

        if duration then
            unit:AddNewModifier(caster, nil, "modifier_kill", {duration=duration})
        else
            table.insert(hero.units, unit)
        end

        -- Add all current upgrades
        PMP:ApplyAllUpgrades(playerID, unit)

        -- Move to rally point
        Timers:CreateTimer(0.05, function() 
            unit:MoveToPosition(caster.rally_point)
        end)
    end

    ability:StartCooldown(ability:GetCooldown(1))
end

function SpawnSuperUnit( event )
    local caster = event.caster
    local owner = caster:GetOwner()
    local player = caster:GetPlayerOwner()
    local playerID = player:GetPlayerID()
    local hero = player:GetAssignedHero()
    local ability = event.ability
    local unit_name = event.UnitName
    local duration = event.Duration
    local position = caster:GetAbsOrigin()
    local teamID = caster:GetTeam()


    local unit = CreateUnitByName(unit_name, position, true, owner, owner, caster:GetTeamNumber())
    unit:SetOwner(hero)
    unit:SetControllableByPlayer(playerID, true)
    FindClearSpaceForUnit(unit, position, true)

    unit:AddNewModifier(caster, nil, "modifier_kill", {duration=duration})
    table.insert(hero.units, unit)
end