function SpawnUnit( event )
    local caster = event.caster
    local playerID = caster:GetPlayerOwnerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local ability = event.ability
    local holdAbility = caster:FindAbilityByName("hold_peons")
    local unit_name = event.UnitName
    local position = caster:GetAbsOrigin()

    -- Don't spawn while disconnected
    local state = PlayerResource:GetConnectionState(playerID)
    if not (state == DOTA_CONNECTION_STATE_CONNECTED or state == DOTA_CONNECTION_STATE_NOT_YET_CONNECTED) then
        return
    end

    local food_cost = GetFoodCost(unit_name)
    local numSpawns = GetSpawnRate(playerID)

    -- Update spawn position to the current active outpost
    local activeOutpost = GetActiveOutpost(playerID)
    if activeOutpost then
        position = activeOutpost:GetAbsOrigin()
    end

    -- Don't spawn more than 1 leader
    if string.match(unit_name,"_leader") then
        numSpawns = 1
    end

    -- If we are holding peons, don't send them to the waypoint yet
    local bHolding = caster.HoldingPeons

    for i=1,numSpawns do

        Timers:CreateTimer(i*0.03, function()
            if not PlayerHasEnoughFood(playerID, food_cost) then
                return
            else
                ModifyFoodUsed(playerID, food_cost)
            end

            local unit = CreateUnitByName(unit_name, position, true, hero, hero, caster:GetTeamNumber())

            if bHolding then
                ApplyModifier(unit, "modifier_hide")
                unit:AddNoDraw()
                caster.held_units = caster.held_units + 1
                if not caster:HasModifier("modifier_hold_peons") then
                    holdAbility:ApplyDataDrivenModifier(caster, caster, "modifier_hold_peons", {})
                end
                caster:SetModifierStackCount("modifier_hold_peons", caster, caster.held_units)
            else                
                unit:SetOwner(hero)
                unit:SetControllableByPlayer(playerID, true)
                FindClearSpaceForUnit(unit, position, true)
            end

            table.insert(hero.units, unit)

            -- Mark the unit as 'core'
            unit.pmp = true

            -- Add all current upgrades
            PMP:ApplyAllUpgrades(playerID, unit)

            -- Play Spawn sound
            if i == 1 and not bHolding then
                Sounds:PlaySoundSet( playerID, unit, "SPAWN" )
            end

            -- Move to rally point
            if not bHolding then
                Timers:CreateTimer(0.05, function() 
                    unit:MoveToPositionAggressive(caster.rally_point)
                    if IsLeaderUnit(unit) and not unit:HasAbility("goblin_attack") and not unit:HasAbility("demon_evasion") then
                        ApplyModifier(unit, "modifier_disable_autoattack")
                    end
                end)
            else
                HidePropWearables(unit)
            end
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

    local charges = caster:GetModifierStackCount("modifier_super_unit_charges", caster)
    if charges and charges > 0 then
        local unit = CreateUnitByName(unit_name, position, true, owner, owner, caster:GetTeamNumber())
        unit:SetOwner(hero)
        unit:SetControllableByPlayer(playerID, true)
        FindClearSpaceForUnit(unit, position, true)

        if unit:GetUnitName() == "super_treant" then AddAnimationTranslate(unit, "torment") end

        unit:AddNewModifier(caster, nil, "modifier_kill", {duration=duration})
        unit:SetIdleAcquire(true)
        Timers:CreateTimer(0.1, function()
            ExecuteOrderFromTable({UnitIndex = unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE, Position = unit:GetAbsOrigin(), Queue = 0}) 
            if PlayerResource:IsFakeClient(playerID) then
                SuperUnitAI:Start(playerID, unit)
            end
        end)
        
        charges = charges - 1
        caster:SetModifierStackCount("modifier_super_unit_charges", caster, charges)
        ability:SetLevel(charges)

        hero.super_peons_used = hero.super_peons_used + 1

        if charges == 0 then
            local endAbility = TeachAbility(caster, "summon_super_peon_empty")
            caster:SwapAbilities("summon_super_peon", "summon_super_peon_empty", false, true)
        end
    end
end

function SuperPeonCharges( event )
    Timers:CreateTimer(0.1, function()
        local ability = event.ability
        local caster = event.caster
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_super_unit_charges", {})
        caster:SetModifierStackCount("modifier_super_unit_charges", caster, 3)
    end)
end