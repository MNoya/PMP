function SpawnTreants( event )
    local caster = event.caster
    local target = event.target
    local playerID = caster:GetPlayerOwnerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local ability = event.ability
    local treant_count = ability:GetLevelSpecialValueFor( "treant_count", ability:GetLevel() - 1 )
    local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
    local unit_name = "treant"
    local origin = target:GetOrigin()
    local teamNumber = caster:GetTeamNumber()

    target:CutDownRegrowAfter(5, teamNumber )

    -- Play the particle
    local particleName = "particles/units/heroes/hero_furion/furion_force_of_nature_cast.vpcf"
    local particle1 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
    ParticleManager:SetParticleControl( particle1, 0, origin )
    ParticleManager:SetParticleControl( particle1, 1, origin )
    ParticleManager:SetParticleControl( particle1, 2, Vector(100,0,0) )

    local gridPoints = GetGridAroundPoint(treant_count, origin)

    for i=1,treant_count do
        local unit = CreateUnitByName(unit_name, origin, true, hero, hero, teamNumber)
        unit:SetControllableByPlayer(playerID, true)
        unit:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
        FindClearSpaceForUnit(unit, gridPoints[i], true)
        unit.summoned = true
        
        local playerUnits = GetPlayerUnits(playerID)
        table.insert(playerUnits, unit)
        
        -- Mark the unit as 'core'
        unit.pmp = true

        -- Add all current upgrades
        PMP:ApplyAllUpgrades(playerID, unit)

    end
end
