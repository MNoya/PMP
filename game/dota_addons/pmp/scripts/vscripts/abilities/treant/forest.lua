--[[
    particles/custom/treant/forest.vpcf
    particles/custom/treant/green.vpcf  
    particles/custom/treant/treant_leech_seed.vpcf
    particles/custom/treant/overgrowth_cast.vpcf
    particles/custom/treant/link.vpcf
]]

function LinkStart( event )
    local caster = event.caster
    local target = event.target
    local ability = event.ability

    if target:GetUnitName() == "treant" then
        local link_time = ability:GetSpecialValueFor("link_time")
        ability:ApplyDataDrivenModifier(caster, target, "modifier_treant_linking", {duration=link_time})
        --print("Link Started")

        --StartAnimation(target, {duration=2, activity=treant_animations[1], rate=0.5})
    end
end

function LinkThink( event )
    local target = event.target
    local radius = 300

    local resultGroup = GetTreantGroup(target, radius)
    local treantCount = resultGroup.unitCount

    local linkTree = FindClosestTreantToLink(target, radius)

    if linkTree and target.linkTarget and target.linkTarget ~= linkTree then
        CreateParticleLink( target, linkTree )
    end

    local max_stacks = 10
    if treantCount > max_stacks then treantCount = max_stacks end

    SetForestStacks(target, treantCount)
end

function LinkingCheck( event )
    local target = event.target
    local radius = 300

    local treeOrigin = FindClosestTreant(target, radius)

    if treeOrigin then
        target.skipLink = nil
        local particleName = "particles/custom/treant/treant_leech_seed.vpcf"
        local leech = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, treeOrigin)
        ParticleManager:SetParticleControlEnt(leech, 0, treeOrigin, PATTACH_POINT_FOLLOW, "attach_hitloc", treeOrigin:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(leech, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

        local modifier = target:FindModifierByName("modifier_treant_linking")
        if modifier then
            local elapsedTime = modifier:GetElapsedTime()
            if elapsedTime >= 5 then
                StartAnimation(target, {duration=2, activity=treant_animations[4], rate=1})
                Timers:CreateTimer(1, function()
                    local particleTree = "particles/custom/treant/overgrowth_cast.vpcf"
                    ParticleManager:CreateParticle(particleTree, PATTACH_ABSORIGIN_FOLLOW, target)
                end)
            elseif elapsedTime >= 3 then
                StartAnimation(target, {duration=2, activity=treant_animations[3], rate=0.5})
            else
                StartAnimation(target, {duration=2, activity=treant_animations[2], rate=0.5})
            end            
        end
    end
end

treant_animations = {
    [1] = ACT_DOTA_CAST_ABILITY_1,
    [2] = ACT_DOTA_CAST_ABILITY_3,
    [3] = ACT_DOTA_CAST_ABILITY_4,
    [4] = ACT_DOTA_CAST_ABILITY_5
}

function StopLinking( event )
    local target = event.unit
    target:RemoveModifierByName("modifier_treant_linking")
    target:RemoveModifierByName("modifier_treant_proximity")
    target.skipLink = true
end

function LinkStablished( event )
    local caster = event.caster
    local target = event.target
    if target.skipLink then 
        target.skipLink = nil
        return
    end
    local ability = event.ability
    local radius = ability:GetCastRange()

    Timers:CreateTimer(function() 
        -- Check if still in range of a treant
        local resultGroup = GetTreantGroup(target, radius)
        local nearbyTreants = resultGroup.unitList
        local treantCount = resultGroup.unitCount

        --print("Treant Count for",target:GetEntityIndex(),"Is",treantCount)

        if treantCount > 0 then
            --print("Link Stablished")

            local max_stacks = 10

            if treantCount > max_stacks then treantCount = max_stacks end

            for k,v in pairs(nearbyTreants) do
                SetForestStacks(v, treantCount)
            end

            if target:HasModifier("modifier_forest_link") then
                CreateParticleLink(target, caster)
            end
        end
    end)
end

function CreateParticleLink( owner, target )
    if owner.particleLink then
        ParticleManager:DestroyParticle(owner.particleLink, false)
        owner.particleLink = nil
    end  

    -- Add tether link on the new linked treant
    -- Each linked tree has his own link to another
    local particleName = "particles/custom/treant/tether/wisp_tether.vpcf" --"particles/custom/treant/link.vpcf"
    owner.particleLink = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, owner)
    ParticleManager:SetParticleControlEnt(owner.particleLink, 0, owner, PATTACH_POINT_FOLLOW, "attach_hitloc", owner:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(owner.particleLink, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    owner.linkTarget = target

    --print("Created particle link, owner:",owner:GetEntityIndex(),"target:",target:GetEntityIndex())
end

function BreakLink( event )
    --print("Break Link")

    local caster = event.caster
    local target = event.target
    local radius = 300

    local modifierName = "modifier_forest_link"
    target:RemoveModifierByName(modifierName)
    target.skipLink = true
end

function CheckParticleLinks( event )
    local caster = event.caster
    local target = caster.linkTarget
    if caster.particleLink and (not IsValidAlive(target) or caster:GetRangeToUnit(target) > 300) then
        ParticleManager:DestroyParticle(caster.particleLink, false)
        caster.particleLink = nil

        --print("Destroyed particle link on caster:",caster:GetEntityIndex())
    end
end

function RemoveLink( event )
    local caster = event.caster
    ParticleManager:DestroyParticle(caster.particleLink, false)
    caster.particleLink = nil
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
                --print("Destroyed particle link on unit:",unit:GetEntityIndex())
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

function FindClosestTreant( unit, radius )
    local units = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES, FIND_CLOSEST, true)
    local treant
    for k,v in pairs(units) do
        if v ~= unit and v:GetUnitName() == "treant" then
            return v
        end
    end
end

function FindClosestTreantToLink( unit, radius )
    local units = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES, FIND_CLOSEST, true)
    local treant
    for k,v in pairs(units) do
        if v ~= unit and v:GetUnitName() == "treant" and v:HasModifier("modifier_forest_link") then
            return v
        end
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
    local units = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), unit, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES, FIND_ANY_ORDER, true)

    if units then
        -- Add to group
        for k,v in pairs(units) do
            local index = v:GetEntityIndex()
            if not group[index] and v:GetUnitName() == "treant" then
                if not v:HasModifier("modifier_treant_linking") then
                    group[index] = v
                    RecursiveFind(v, radius, group)
                end
            end
        end
    else
        return group
    end
end