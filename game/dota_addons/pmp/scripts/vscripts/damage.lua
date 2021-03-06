function PMP:FilterDamage( filterTable )
	--for k, v in pairs( filterTable ) do
	--	print("Damage: " .. k .. " " .. tostring(v) )
	--end
	local victim_index = filterTable["entindex_victim_const"]
	local attacker_index = filterTable["entindex_attacker_const"]
	if not victim_index or not attacker_index then
		return true
	end

	local victim = EntIndexToHScript( victim_index )
	local attacker = EntIndexToHScript( attacker_index )
	local damagetype = filterTable["damagetype_const"]

	-- Physical attack damage filtering
	if damagetype == DAMAGE_TYPE_PHYSICAL then
		local damage = filterTable["damage"] --Post reduction

        if IsSuperPeon(attacker) and IsBoss(victim) then
            return false
        end

        if IsCityCenter(attacker) and not IsBoss(victim) then
            if victim:GetHealthPercent() > 70 then
                local hp = victim:GetHealth()
                victim:SetHealth(hp - (hp*0.70))
            else
                victim:Kill(nil, attacker)
            end
            return false
        end
		
		-- Reassign the new damage
		filterTable["damage"] = damage
    end

	return true
end

DAMAGE_TYPES = {
    [0] = "DAMAGE_TYPE_NONE",
    [1] = "DAMAGE_TYPE_PHYSICAL",
    [2] = "DAMAGE_TYPE_MAGICAL",
    [4] = "DAMAGE_TYPE_PURE",
    [7] = "DAMAGE_TYPE_ALL",
    [8] = "DAMAGE_TYPE_HP_REMOVAL",
}
