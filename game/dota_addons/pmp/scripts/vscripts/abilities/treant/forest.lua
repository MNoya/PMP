MAX_FOREST = 10


--[[

    particles/econ/courier/courier_trail_fungal/courier_trail_fungal.vpcf
    particles/econ/courier/courier_greevil_green/courier_greevil_green_ambient_3.vpcf
    particles/econ/courier/courier_shagbark/courier_shagbark_butterflies.vpcf
    particles/units/heroes/hero_treant/treant_overgrowth_vine_glow_trail.vpcf
    particles/units/heroes/hero_treant/treant_overgrowth_vines.vpcf
    particles/units/heroes/hero_treant/treant_overgrowth_cast_tree.vpcf
    particles/units/heroes/hero_treant/treant_overgrowth_ambient_beam_sparkly.vpcf
    particles/units/heroes/hero_treant/treant_leech_seed.vpcf
    particles/units/heroes/hero_treant/treant_eyesintheforest.vpcf

    particles/units/heroes/hero_treant/treant_leech_seed_rope.vpcf
]]

function LinkStart( event )
    local caster = event.caster
    local target = event.target
    local ability = event.ability

    if target:GetUnitName() == "treant" then
        local link_time = ability:GetSpecialValueFor("link_time")
        ability:ApplyDataDrivenModifier(caster, target, "modifier_treant_linking", {duration=link_time})
        print("Link Started")
    end
end

function LinkThink( event )
    local target = event.target
    local ability = event.ability
    local radius = ability:GetCastRange()

    local resultGroup = GetTreantGroup(target, radius)
    local treantCount = resultGroup.unitCount

    SetForestStacks(target, treantCount)
end

function LinkStablished( event )
    local caster = event.caster
    local target = event.target
    local ability = event.ability
    local radius = ability:GetCastRange()

    -- Check if still in range of a treant
    local resultGroup = GetTreantGroup(target, radius)
    local nearbyTreants = resultGroup.unitList
    local treantCount = resultGroup.unitCount

    if treantCount > 0 then
        print("Link Stablished")
        local modifierName = "modifier_forest_link"

        if treantCount > MAX_FOREST then treantCount = MAX_FOREST end

        for k,v in pairs(nearbyTreants) do
            SetForestStacks(v, treantCount)
        end

        -- Add tether link on the new linked treant
        local particleName = "particles/units/heroes/hero_wisp/wisp_tether.vpcf"
        target.particleLink = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(target.particleLink, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(target.particleLink, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    end
end

function BreakLink( event )
    print("Break Link")

    local caster = event.caster
    local target = event.target
    local radius = 300

    local modifierName = "modifier_forest_link"
    local modifier = target:FindModifierByName(modifierName)

    target:RemoveModifierByName(modifierName)
end

function SetForestStacks( unit, number )
    local modifierName = "modifier_forest_link"
    local modifier = nil

    if unit:HasModifier(modifierName) then
        modifier = unit:FindModifierByName(modifierName)
        if number == 0 then
            if unit.particleLink then
                ParticleManager:DestroyParticle(unit.particleLink, false)
                unit.particleLink = nil
            end
            unit:RemoveModifierByName(modifierName)
        else
            modifier:SetStackCount(number)
        end
    else
        local ability = unit:FindAbilityByName("treant_racial")
        ability:ApplyDataDrivenModifier(unit, unit, modifierName, {})

        modifier = unit:FindModifierByName(modifierName)
        modifier:SetStackCount(number)
    end
end

-- Returns the table and count of treants standing together
function GetTreantGroup( startingUnit, radius )
    local groupedUnits = {}

    RecursiveFind(startingUnit, radius, groupedUnits)

    local countTreants = 0
    for k,v in pairs(groupedUnits) do
        countTreants = countTreants + 1
    end

    -- Groups of 1 aren't really groups sorry buddy
    if countTreants == 1 then
        groupedUnits = {}
        countTreants = 0
    end

    local result = {}
    result.unitList = groupedUnits
    result.unitCount = countTreants

    return result
end

function RecursiveFind( unit, radius, group )
    local units = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES, FIND_ANY_ORDER, true)

    if units then
        -- Add to group
        for k,v in pairs(units) do
            local index = v:GetEntityIndex()
            if not group[index] and v:GetUnitName() == "treant" and not v:HasModifier("modifier_treant_linking") then
                group[index] = v
                RecursiveFind(v, radius, group)
            end
        end
    else
        return group
    end
end