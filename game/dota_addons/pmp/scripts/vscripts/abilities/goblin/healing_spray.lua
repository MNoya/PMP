function HealingSprayStart( event )
	local caster = event.caster
	local point = event.target_points[1]

	caster.healing_spray_dummy = CreateUnitByName("dummy_unit_vulnerable", point, false, caster, caster, caster:GetTeam())
	event.ability:ApplyDataDrivenModifier(caster, caster.healing_spray_dummy, "modifier_healing_spray_thinker", nil)
end


function HealingSprayWave( event )
	local caster = event.caster
	local point = event.target:GetAbsOrigin()
	local radius = event.ability:GetSpecialValueFor("radius")

	local particleName = "particles/custom/goblin/alchemist_acid_spray_cast.vpcf"
	local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(particle, 1, point)
	ParticleManager:SetParticleControl(particle, 15, Vector(255,255,0))
	ParticleManager:SetParticleControl(particle, 16, Vector(255,255,0))

	local particleName2 = "particles/custom/goblin/alchemist_acid_spray.vpcf"
	local particle2 = ParticleManager:CreateParticle(particleName2, PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle2, 1, Vector(radius, 1, radius))
	ParticleManager:SetParticleControl(particle, 15, Vector(255,255,0))
	ParticleManager:SetParticleControl(particle, 16, Vector(255,255,0))
end

function HealingSprayEnd( event )
	local caster = event.caster

	caster.healing_spray_dummy:RemoveSelf()
end