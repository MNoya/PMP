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

        if GetRace(attacker) == "night_elf" then
            local armor_victim = GetArmorType(victim)
            if armor_victim == "medium" then
                damage = damage * (2/3) -- Put piercing damage to 50% from 75%
            elseif armor_victim == "unarmored" then
                damage = damage * 0.5 -- Put piercing damage to 100% from 200%
            end
        elseif GetRace(victim) == "night_elf" then
            local attack_attacker = GetAttackType(attacker)
            if attack_attacker == "normal" then
                damage = damage * 1.5 -- Take 150% damage from melee attacks
            end
        end

        if IsSuperPeon(attacker) and IsBoss(victim) then
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
