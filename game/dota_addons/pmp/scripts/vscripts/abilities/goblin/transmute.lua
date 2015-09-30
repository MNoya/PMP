function Transmute( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local gold_bounty_multiplier = ability:GetLevelSpecialValueFor( "gold_bounty_multiplier" , ability:GetLevel() - 1  )

	if target:GetLevel() < 6 then
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