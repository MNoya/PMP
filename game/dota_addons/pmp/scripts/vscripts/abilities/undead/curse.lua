function BansheeCurseAuto_Cast(event)
    local ability = event.ability
    local caster = event.caster
    local AUTOCAST_RANGE = ability:GetCastRange()
    local MODIFIER_NAME = "modifier_undead_curse"
    
    if ability:GetAutoCastState() and ability:IsFullyCastable() then

        -- find enemy units within range
        local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), 
                                    nil, AUTOCAST_RANGE, DOTA_UNIT_TARGET_TEAM_ENEMY, 
                                    DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 
                                    FIND_CLOSEST, false)
        local target        
        for k,unit in pairs(units) do
            if not unit:HasModifier(MODIFIER_NAME) and not IsCustomBuilding(unit) then
                target = unit
                break
            end
        end
        
        if target then
            caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
            caster:CastAbilityOnTarget(target, ability, caster:GetPlayerOwnerID())  
        end
    end
end