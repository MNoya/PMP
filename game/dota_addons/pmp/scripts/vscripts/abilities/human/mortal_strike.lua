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

            local casterOrigin = caster:GetAbsOrigin()
            local fv = caster:GetForwardVector()
            fv.z = 0.1

            Physics:Unit(target)
            target:PreventDI(true)
            target:FollowNavMesh(false)
            target:SetNavCollisionType(PHYSICS_NAV_NOTHING)
            target:SetPhysicsVelocity(fv * 3000)
            target:SetPhysicsAcceleration(Vector(0,0,-1000))
            target:SetPhysicsFriction(0.1)
            
            target:Kill(ability, caster)

            Timers:CreateTimer(0.5, function()
                target:SetPhysicsVelocity(Vector(0,0,0))
                target:PreventDI(false)
            end)         
        end
    end
end