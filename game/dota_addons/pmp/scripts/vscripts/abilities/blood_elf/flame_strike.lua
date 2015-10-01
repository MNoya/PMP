function FlameStrikeAnimation1( event )
    local caster = event.caster

    StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_SUN_STRIKE, rate=1, translate="divine_sorrow_sunstrike"})
end

function FlameStrikeAnimation2( event )
    local caster = event.caster

    StartAnimation(caster, {duration=1, activity=ACT_DOTA_CAST_SUN_STRIKE, rate=1})
end