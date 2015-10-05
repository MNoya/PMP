function MassWindWalk( event )
    local caster = event.caster
    local ability = event.ability

    local radius = ability:GetSpecialValueFor("radius")
    local duration = ability:GetSpecialValueFor("duration")

    local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, 0, DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES, false)

    for k,unit in pairs(units) do
        ability:ApplyDataDrivenModifier(caster, unit, "modifier_night_elf_windwalk", {duration=duration})
    end

    ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_moonlight_ray.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_starfall_moonray.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
end