function AttackStance( event )
    local caster = event.caster

    caster:AddNewModifier(caster, nil, "modifier_animation_translate", {translate="chemical_rage"})
    caster:SetModifierStackCount("modifier_animation_translate", caster, 2)
end