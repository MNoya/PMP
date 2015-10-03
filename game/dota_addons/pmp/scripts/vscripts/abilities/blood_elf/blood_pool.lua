function CreatePool( event )
    local caster = event.caster
    local ability = event.ability
    local owner = caster:GetOwner()
    local origin = caster:GetAbsOrigin()
    local team = caster:GetTeamNumber()

    local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel()-1)

    local dummy = CreateUnitByName("dummy_unit_vulnerable", caster:GetAbsOrigin(), false, owner, owner, caster:GetTeamNumber())
    TeachAbility(dummy, ability:GetAbilityName(), ability:GetLevel())

    ParticleManager:CreateParticle("particles/custom/blood_elf/blood_pool.vpcf", 0, dummy)

    ability:ApplyDataDrivenModifier(caster, dummy, "modifier_blood_pool", {duration=duration})

    Timers:CreateTimer(duration, function() UTIL_Remove(dummy) end)

end

function CheckTarget(event)
    local caster = event.caster --The blood pool
    local target = event.target

    if caster:GetOwner() == target:GetOwner() then
        local ability = caster:FindAbilityByName("blood_elf_racial")
        if ability then
            local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel()-1)
            ability:ApplyDataDrivenModifier(caster, target, "modifier_blood_pool_regen", {})
        end
    end
end