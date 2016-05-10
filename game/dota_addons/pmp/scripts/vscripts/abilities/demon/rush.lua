function CheckAggro( event )
    local unit = event.target
    local target = unit:GetAggroTarget()
    if target then
        if unit:GetRangeToUnit(target) < 900 then
            unit:SetForceAttackTarget(target)
            Timers:CreateTimer(0.1, function() unit:SetForceAttackTarget(nil) end)
            local ability = event.ability
            if ability then
                ability:ApplyDataDrivenModifier(unit, unit, "modifier_demon_rush_dash", {})
            end
        end
    else
        if unit:HasModifier("modifier_demon_rush_dash") then
            unit:RemoveModifierByName("modifier_demon_rush_dash")
        end
    end
end

function AutocastLogic( event )
    local caster = event.caster
    local ability = event.ability
    if not ability then return end
    local autocast_radius = ability:GetCastRange() or 900
    local modifierName = "modifier_demon_rush"

    -- Get if the ability is on autocast mode and cast the ability on a valid target
    if (caster:IsIdle() or caster:IsAttacking()) and ability:GetAutoCastState() and ability:IsFullyCastable() and ability:IsCooldownReady() and not caster:IsSilenced() then
        -- Find damaged targets in radius
        local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, autocast_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_FARTHEST, false)
        for k,unit in pairs(allies) do
            if not IsCustomBuilding(unit) and not unit:HasModifier(modifierName) then
                caster:CastAbilityOnTarget(unit, ability, caster:GetPlayerOwnerID())
                return
            end
        end
    end 
end