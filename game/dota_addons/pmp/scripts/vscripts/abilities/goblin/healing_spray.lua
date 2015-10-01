function HealingSprayAnimation( event )
	local caster = event.caster

	caster:EmitSound("Hero_Alchemist.ChemicalRage.Cast")
	StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_ALCHEMIST_CONCOCTION, rate=1})

	caster:RemoveModifierByName("modifier_animation_translate")
end


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

	local target = caster.healing_spray_dummy

	local particleName2 = "particles/custom/goblin/alchemist_acid_spray.vpcf"
	local particle2 = ParticleManager:CreateParticle(particleName2, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle2, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle2, 1, Vector(radius, 1, radius))
	ParticleManager:SetParticleControl(particle2, 15, Vector(255,255,0))
	ParticleManager:SetParticleControl(particle2, 16, Vector(255,255,0))

	Timers:CreateTimer(1, function() ParticleManager:DestroyParticle(particle2, true) end)

	StartAnimation(caster, {duration=0.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=1})
end

function HealingSprayEnd( event )
	local caster = event.caster

	UTIL_Remove(caster.healing_spray_dummy)

	caster:AddNewModifier(caster, nil, "modifier_animation_translate", {translate="chemical_rage"})
    caster:SetModifierStackCount("modifier_animation_translate", caster, 2)
end