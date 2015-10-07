skeleton_sacrifice = class ({})

function skeleton_sacrifice:OnAbilityPhaseStart()
    local ability = self
    local caster = ability:GetCaster()
    local target = ability:GetCursorTarget()

    StartAnimation(caster, {duration=1.5, activity=ACT_DOTA_CAST_ABILITY_4, rate=1.5, translate="death_protest"})

    local particleName = "particles/units/heroes/hero_necrolyte/necrolyte_scythe_orig.vpcf"
    local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, target)
    ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())

    target:EmitSound("Hero_Necrolyte.ReapersScythe.Target")

    return true
end

function skeleton_sacrifice:OnSpellStart()
    local ability = self

    local caster = ability:GetCaster()
    local target = ability:GetCursorTarget()
    local level = ability:GetLevel()
    local playerID = caster:GetPlayerOwnerID()

    target:ForceKill(true) 
    local origin = target:GetAbsOrigin()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)

    Timers:CreateTimer(0.5, function()
        local shade = CreateUnitByName("skeleton_shade", origin, true, hero, hero, caster:GetTeamNumber())
        shade:SetControllableByPlayer(playerID, true)
        shade:AddNewModifier(caster, ability, "modifier_invisible", {})

        FindClearSpaceForUnit(shade, origin, true)
    end)
end

--------------------------------------------------------------------------------
 
function skeleton_sacrifice:CastFilterResultTarget( target )
    local ability = self
    local caster = ability:GetCaster()

    -- Check for skeletons only controlled by the player
    local bOwner = caster:GetPlayerOwnerID() == target:GetPlayerOwnerID()
    local bSkeleton = target:GetUnitName() == "skeleton"

    if not bOwner or not bSkeleton then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end
  
function skeleton_sacrifice:GetCustomCastErrorTarget( target )
    local ability = self
    local caster = self:GetCaster()

    local bOwner = caster:GetPlayerOwnerID() == target:GetPlayerOwnerID()
    local bSkeleton = target:GetUnitName() == "skeleton"

    if not bOwner then
        return "#error_must_target_own_units"
    end

    if not bSkeleton then
        return "#error_must_target_skeleton"
    end
 
    return ""
end