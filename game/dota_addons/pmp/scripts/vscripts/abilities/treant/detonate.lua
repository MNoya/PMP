function Detonate( event )
    local caster = event.caster
    local point = event.target_points[1]
    local ability = event.ability
    local radius = ability:GetSpecialValueFor("radius")
    local kill_chance = ability:GetSpecialValueFor("kill_chance")

    local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    for k,unit in pairs(units) do
        local bRemovePositiveBuffs = false
        local bRemoveDebuffs = false
        local bFrameOnly = false
        local bRemoveStuns = false
        local bRemoveExceptions = false

        -- Remove buffs on enemies or debuffs on allies
        local bEnemy = unit:GetTeamNumber() ~= caster:GetTeamNumber()
        if bEnemy then
            bRemovePositiveBuffs = true
            if RollPercentage(kill_chance) then
                local killParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_guardian_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
                unit:Kill(ability, caster)
            end
        else
            bRemoveDebuffs = true
        end

        unit:Purge(bRemovePositiveBuffs, bRemoveDebuffs, bFrameOnly, bRemoveStuns, bRemoveExceptions)
    end

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_dispel_magic.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, point)
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, 0,0 ))

    local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_guardian_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(particle2, 0, point)

    local particle3 = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_death.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(particle3, 0, point)

    caster:EmitSound("Hero_Wisp.TeleportOut")
    caster:ForceKill(true)
end