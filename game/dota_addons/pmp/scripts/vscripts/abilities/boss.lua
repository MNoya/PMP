function Devour( event )
    local boss = event.caster
    local target = event.target

    for i=0,15 do
        local ability = target:GetAbilityByIndex(i)
        if ability then
            local abilityName = ability:GetAbilityName()
            if not boss:HasAbility(abilityName) then
                TeachAbility(boss, abilityName)
            end
        end
    end

    AdjustAbilityLayout(boss)

    HideUnit(target)
    target:ForceKill(true)
end

function ApplyStacks( event )
    local boss = event.caster
    local ability = event.ability
    local modifierName = "modifier_boss_stacks"
    
    local time = GameRules:GetDOTATime(false, true)
    print("Boss spawned at ",time)
    local stacks = math.floor(time / 180)

    if stacks <= 0 then return end
    
    ability:ApplyDataDrivenModifier(boss, boss, modifierName, {})
    boss:SetModifierStackCount(modifierName, boss, stacks)

    -- Scale
    local increase = 0.2*math.log(tonumber(stacks+1),2)
    local scale = 0.8+increase
    boss:SetModelScale(scale)

    -- Health
    local health = 2000+1000*stacks
    local relativeHealth = boss:GetHealthPercent()
    boss:SetBaseMaxHealth(health)
    boss:SetMaxHealth(health)
    boss:SetHealth(math.ceil(boss:GetMaxHealth() * relativeHealth))
end

function UpdateStacks( event )
    local boss = event.caster
    local ability = event.ability
    local modifierName = "modifier_boss_stacks"
    
    local time = GameRules:GetDOTATime(false, true)
    local stacks = math.floor(time / 180)

    -- Roam
    if GameRules.BossRoam then
        local randomPoint = RandomInt(1,#boss.roamPoints)
        DeepPrintTable(boss.roamPoints)
        local ent = boss.roamPoints[randomPoint]
        local position = ent:GetAbsOrigin()
        ExecuteOrderFromTable({ UnitIndex = boss:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = position, Queue = false}) 
    end

    if stacks <= 0 then return end

    if boss:HasModifier(modifierName) then
        boss:SetModifierStackCount(modifierName, boss, stacks)
    else
        ability:ApplyDataDrivenModifier(boss, boss, modifierName, {})
        boss:SetModifierStackCount(modifierName, boss, stacks)
    end

    -- Scale
    local increase = 0.2*math.log(tonumber(stacks+1),2)
    local scale = 0.8+increase
    boss:SetModelScale(scale)

    -- Health
    local health = 2000+1000*stacks
    local relativeHealth = boss:GetHealthPercent() * 0.01
    boss:SetBaseMaxHealth(health)
    boss:SetMaxHealth(health)
    boss:SetHealth(math.ceil(boss:GetMaxHealth() * relativeHealth))
end

function StartRespawn( event )
    local boss = event.caster
    local time_to_respawn = 300

    print("[PMP] Boss Killed, respawning in "..time_to_respawn.." seconds")
    GameRules.TimesBossKilled = GameRules.TimesBossKilled and (GameRules.TimesBossKilled + 1) or 1

    Timers:CreateTimer(time_to_respawn, function() 
        PMP:SpawnBoss()
    end)
end