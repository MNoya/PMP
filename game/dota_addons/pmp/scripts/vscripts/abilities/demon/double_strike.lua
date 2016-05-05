function OnAttackLanded(event)
    local caster = event.caster
    local target = event.target
    local ability = event.ability

    if caster:HasModifier("modifier_demon_rush") then
        caster.double_strike = true
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_demon_double_strike", {duration=1})
        return
    end

    if not caster.double_strike then
        local chance = ability:GetLevelSpecialValueFor("double_strike_chance_pct", ability:GetLevel()-1)

        if RollPercentage(chance) then   
            caster.double_strike = true
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_demon_double_strike", {duration=1})
        end
    else
        caster.double_strike = false
    end
end