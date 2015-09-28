function FrenzyAttack( event )
    local caster = event.caster
    local ability = event.ability
    local modifierName = "modifier_peon_frenzy_stacks"
    local duration = ability:GetSpecialValueFor("duration")

    -- Applying refreshes the modifier
    ability:ApplyDataDrivenModifier(caster, caster, modifierName, {duration=duration})

    local stackCount = caster:GetModifierStackCount(modifierName, caster) or 0
    stackCount = stackCount == 5 and 5 or (stackCount + 1)

    caster:SetModifierStackCount(modifierName, caster, stackCount)        
end