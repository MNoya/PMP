-- Handles AutoCast Logic
function HealAutocast( event )
    local caster = event.caster
    local ability = event.ability
    local autocast_radius = ability:GetSpecialValueFor("autocast_radius")

    -- Get if the ability is on autocast mode and cast the ability on a valid target
    if ability:GetAutoCastState() and ability:IsFullyCastable() and not caster:IsSilenced() then
        -- Find damaged targets in radius
        local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, autocast_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
        for k,unit in pairs(allies) do
            if not IsCustomBuilding(unit) and unit:GetHealthDeficit() > 0 then
                caster:CastAbilityOnTarget(unit, ability, caster:GetPlayerOwnerID())
                return
            end
        end
    end 
end