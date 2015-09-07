function Cleave( event )
    local caster = event.caster
    local target = event.target
    local targets = event.target_entities
    local cleave_percent = event.ability:GetSpecialValueFor("cleave_percent") * 0.01
    local damage = event.Damage * cleave_percent

    for k,v in pairs(targets) do
        if v ~= target then
            ApplyDamage({ victim = v, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE}) 
        end
    end
end