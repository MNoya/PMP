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

		local lumber_bounty = GetLumberBounty(target)
        local gold_gained = GetGoldBounty(target) * gold_bounty_multiplier

        local playerID = caster:GetPlayerOwnerID()

        ModifyGold(playerID, gold_gained)
        PopupGoldGain(target, gold_gained, caster:GetTeamNumber())

        ModifyLumber(playerID, lumber_bounty)
        PopupLumber(target, lumber_bounty, caster:GetTeamNumber())

        EmitSoundOnClient("General.Coins", PlayerResource:GetPlayer(playerID))	
		
		target:ForceKill(true)
	else
		caster:RefundManaCost()
		ability:EndCooldown()
		caster:Interrupt()
		SendErrorMessage(pID, "#error_cant_target_level6")
	end
end