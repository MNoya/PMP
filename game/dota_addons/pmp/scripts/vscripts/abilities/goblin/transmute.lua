function Transmute( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local gold_bounty_multiplier = ability:GetLevelSpecialValueFor( "gold_bounty_multiplier" , ability:GetLevel() - 1  )

	if target:GetLevel() < 6 then

		target:EmitSound("DOTA_Item.Hand_Of_Midas")

		local particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)

		local particle2 = ParticleManager:CreateParticle("particles/econ/items/alchemist/alchemist_midas_knuckles/alch_hand_of_midas_radial.vpcf", PATTACH_ABSORIGIN, target)

		local gold_gained = target:GetGoldBounty() * gold_bounty_multiplier

		-- Set the gold gained for killing the unit to the new multiplied number
		target:SetMinimumGoldBounty(gold_gained)
		target:SetMaximumGoldBounty(gold_gained)
		target:Kill(ability, caster) --Kill the creep. This increments the caster's last hit counter.
	else
		caster:RefundManaCost()
		ability:EndCooldown()
		caster:Interrupt()
		SendErrorMessage(pID, "#error_cant_target_level6")
	end
end