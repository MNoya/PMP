function MortalStrike( event )
    local caster = event.caster
    local target = event.target
    local chance = event.Chance
    local particleName = "particles/econ/items/dragon_knight/dk_immortal_dragon/dragon_knight_dragon_tail_dragonform_iron_dragon.vpcf"
    
    if IsPimpUnit(target) then
        if RollPercentage(chance) then
            local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster) 
            ParticleManager:SetParticleControlEnt(particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

            local random = RandomInt(3,6)
            local duration = random*0.1
            local casterOrigin = caster:GetAbsOrigin()
            local len = random*100

            local knockbackModifierTable =
            {
                should_stun = true,
                knockback_duration = duration,
                duration = duration,
                knockback_distance = len,
                knockback_height = RandomInt(150,200),
                center_x = casterOrigin.x,
                center_y = casterOrigin.y,
                center_z = casterOrigin.z
            }

            ApplyModifier(target, "modifier_no_health_bar")
            target:AddNewModifier( caster, nil, "modifier_knockback", knockbackModifierTable )
            Timers:CreateTimer(duration,function() target:Kill(ability, caster) end)
        end
    end
end