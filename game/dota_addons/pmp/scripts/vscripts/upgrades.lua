-- This is called after a unit upgrade is purchased
function UpgradeFinished( event )
	local caster = event.caster
	local ability = event.ability
	local pID = caster:GetPlayerOwnerID()
	local lumberCost = ability:GetSpecialValueFor("lumber_cost")

	if not PlayerHasEnoughLumber(pID, lumberCost) then
		return
	else
		ModifyLumber(pID, -lumberCost)
	end

	caster:StartGesture(ACT_DOTA_SPAWN)

	local upgrade_level = tonumber(event.Level)
	local upgrade_name = event.Name

	-- Replace with the next level
	if ability:IsItem() then
		local old_slot = GetItemSlot(caster, ability)
		ability:RemoveSelf()

		-- Add a new item rank if possible
		if upgrade_level < 5 then
			local next_rank = upgrade_level + 1
			local new_item_name = "item_upgrade_"..upgrade_name..next_rank
			local new_item = CreateItem(new_item_name, caster, caster)
			caster:AddItem(new_item)
			local new_slot = GetItemSlot(caster, new_item)
			caster:SwapItems(old_slot, new_slot)
		end
	else
		local old_ability_name = ability:GetAbilityName()
		local next_rank = upgrade_level + 1
		local new_ability_name = "upgrade_"..upgrade_name..next_rank

		caster:AddAbility(new_ability_name)

		local new_ability = caster:FindAbilityByName(new_ability_name)
		if new_ability then
			caster:SwapAbilities(new_ability_name, old_ability_name, true, false)
			caster:RemoveAbility(old_ability_name)

			print("New Rank: "..new_ability_name)
			new_ability:SetLevel(new_ability:GetMaxLevel())
			--new_ability:StartCooldown(1)
			FireGameEvent( 'ability_values_force_check', { player_ID = pID })
		else
			print("Max Rank of "..upgrade_name.." reached!")

			-- Add a filler ability showing the last rank has been reached
			local filler_name = "upgrade_"..upgrade_name.."_final"
			local final = TeachAbility(caster,filler_name ,1)
			caster:SwapAbilities(filler_name, old_ability_name, true, false)			
			
			ability:SetLevel(0)

			FireGameEvent( 'ability_values_force_check', { player_ID = pID })
		end
	end

	PMP:SetUpgrade(pID, upgrade_name, upgrade_level)
end

-- Hero global upgrades
function PimpUpgrade( event )
	local hero = event.caster
	local playerID = hero:GetPlayerID()
	local ability = event.ability
	local level = ability:GetLevel()
	local ability_name = ability:GetAbilityName()

	hero.Upgrades[ability_name] = level

	-- Go through units and update stacks
	local Units = GetPlayerUnits(playerID)
	for _,unit in pairs(Units) do
		PMP:ApplyModifierUpgradeStacks(unit, ability_name, level)
	end

	local Towers = GetPlayerTowers(playerID)
	for _,tower in pairs(Towers) do
		PMP:ApplyModifierUpgradeStacks(tower, ability_name, level)
	end

	-- Add garage damage
	local garage = hero.garage
	if IsValidAlive(garage) then
		PMP:ApplyModifierUpgradeStacks(garage, ability_name, level)
	end
end

function PMP:SetUpgrade( playerID, name, level )
	local upgrades = PMP:GetUpgradeList(playerID)

	upgrades[name] = level
	print("SetUpgrade: "..name.." Level "..level)

	local Units = GetPlayerUnits(playerID)

	-- Apply the upgrade to all units
	for _,unit in pairs(Units) do
		PMP:ApplyUpgrade(unit, name, level)
	end

	-- Health also applies to buildings
	local Buildings = GetPlayerBuildings(playerID)
	if name == "health" then
		for _,unit in pairs(Buildings) do
			PMP:ApplyUpgrade(unit, name, level)
		end
	end		
end

function PMP:GetUpgradeList( playerID )
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	return hero.Upgrades
end

-- OnEntitySpawned, check its name and apply upgrades for the player that owns it
function PMP:ApplyUpgrade(unit, name, level)
	local ability = unit:FindAbilityByName(name)

	if ability then
		ability:SetLevel(level)
	else
		local ability = TeachAbility(unit, name, level)
		if not ability then
			PMP:ApplyModifierUpgrade(unit, name, level)
			
			if not unit.prop_wearables then
				unit.prop_wearables = {}
			end

            local unit_wearables = GetWearablesForUnit(unit)
            if not unit_wearables then
                return
            end

            local slot_type_table = unit_wearables[name]
			if slot_type_table then
            	local level_table = slot_type_table[tostring(level)]	    

            	if level_table then

	        		local model_type = level_table["Type"]
		        	if model_type == "Change" then

		            	SwapWearableInSlot(unit, level_table, name)

		        	elseif model_type == "Attach" then	

		        		AttachWearableInSlot(unit, level_table, name, 0.8)
		        	end
		        end
		    end
	    end
    end

	AdjustAbilityLayout(unit)
end

function PMP:ApplyModifierUpgrade(unit, name, level)
	local targetModifierName = "modifier_"..name
	--unit:RemoveModifierByName(targetModifierName..(level-1))
	local modifiers = unit:FindAllModifiers()
	for i=1,#modifiers do
		local modifierName = unit:GetModifierNameByIndex(i)
		if StringStartsWith(modifierName, targetModifierName) then
			unit:RemoveModifierByName(modifierName)
		end
	end
	GameRules.UPGRADER:ApplyDataDrivenModifier(unit, unit, targetModifierName..level, {})
end

function PMP:ApplyModifierUpgradeStacks( unit, name, level )
	local hero = unit:GetOwner()
	local ability = hero:FindAbilityByName(name)
	local modifierName = "modifier_"..name

	if unit:HasModifier(modifierName) then
		unit:SetModifierStackCount(modifierName, hero, level)
	else
		ability:ApplyDataDrivenModifier(hero, unit, modifierName, {})
		unit:SetModifierStackCount(modifierName, hero, 1)
	end
end

-- Go through all the ugprades of the player and add them to a unit
function PMP:ApplyAllUpgrades(playerID, unit)
	local upgrades = PMP:GetUpgradeList(playerID)

	for name,level in pairs(upgrades) do
		if heroUpgrades[name] then
			if level ~= 0 then
				PMP:ApplyModifierUpgradeStacks(unit, name, level)
			end
		elseif level ~= 0 then
			PMP:ApplyUpgrade(unit, name, level)
		end
	end
end

heroUpgrades = {["pimp_damage"]={},["pimp_armor"]={},["pimp_speed"]={},["pimp_regen"]={}}
slots = {"weapon","helm","shield","wings"}

function PMP:ResetAllUpgrades(playerID)
	local Units = GetPlayerUnits(playerID)
	for _,unit in pairs(Units) do
        for k,slot_name in pairs(slots) do
            ClearPropWearableSlot(unit, slot_name)

            local item_wearable = GetOriginalWearableInSlot(unit, slot_name)
            local default_wearable_name = GetDefaultWearableNameForSlot(unit, slot_name)
            if item_wearable and default_wearable_name then
                item_wearable:SetModel(default_wearable_name)
                item_wearable:RemoveEffects(EF_NODRAW)
            end
        end     
	end
end

function PMP:PrintUpgrades( playerID )
	local upgrades = PMP:GetUpgradeList(playerID)
	DeepPrintTable(upgrades)
end