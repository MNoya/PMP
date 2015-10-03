function FlameStrikeAnimation1( event )
    local caster = event.caster

    StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_SUN_STRIKE, rate=1, translate="divine_sorrow_sunstrike"})
end

function FlameStrikeAnimation2( event )
    local caster = event.caster

    StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_SUN_STRIKE, rate=1})
    local point = event.target_points[1]

    -- Destroy barricades
    local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, 200, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, 0, false)

    for k,v in pairs(units) do
        if v:GetUnitName() == "barricade" then
            v:ForceKill(true)
            ParticleManager:CreateParticle("particles/newplayer_fx/npx_tree_break.vpcf", PATTACH_ABSORIGIN, v)
        end
    end
end