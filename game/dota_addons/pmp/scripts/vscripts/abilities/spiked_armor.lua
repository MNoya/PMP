-- OnAttacked, deal damage based on the attack_damage, only to melee attackers
function Return( event )
    local attacker = event.attacker
    local target = event.target --the damaged unit
    local ability = event.ability
    local abilityDamageType = ability:GetAbilityDamageType()
    local melee_damage_return = ability:GetLevelSpecialValueFor("melee_damage_return", ability:GetLevel() - 1)
    local damage_taken = event.Damage
    local return_damage = damage_taken * 0.01 * melee_damage_return

    if not attacker:IsRangedAttacker() then
        ApplyDamage({ victim = attacker, attacker = target, damage = return_damage, damage_type = abilityDamageType })
    end
end