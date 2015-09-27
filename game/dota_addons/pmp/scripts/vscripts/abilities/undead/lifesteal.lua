-- LifestealApply
function LifestealApply( event )
    -- Variables
    local attacker = event.attacker
    local target = event.target
    local ability = event.ability

    if not IsCustomBuilding(target) and not IsBarricade(target) then
        ability:ApplyDataDrivenModifier(attacker, attacker, "modifier_undead_lifesteal_hit", {duration = 0.03})
    end
end