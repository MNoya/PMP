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

			HATS = LoadKeyValues("scripts/kv/wearables.kv") --Reload for tests
			local race = GetRace(unit)
		    local race_type_table = HATS[race][name]
		    if race_type_table then
		        local level_table = race_type_table[tostring(level)]
		        if level_table then
		            local model = level_table["Model"]
		            local model_type = level_table["Type"]

		            if model_type == "Change" then

		                -- Get original wearable and change its model
		                local item_wearable = PMP:GetOriginalWearableInSlot(unit, name)
		                if not item_wearable then
		                	return
		                end

		               	item_wearable:SetModel(model)
		               	item_wearable:RemoveEffects(EF_NODRAW)
		               	--print("Visible",item_wearable:GetModelName(),name)

		               	-- Clear any prop wearable the unit might have in this slot
		               	ClearPropWearableSlot(unit, name)

		            elseif model_type == "Attach" then

		            	-- Clear any prop wearable the unit might have in this slot
		               	ClearPropWearableSlot(unit, name)

		                -- Get original wearable and hide it
		                local item_wearable = PMP:GetOriginalWearableInSlot(unit, name)
		                if not item_wearable then
		                	return
		                end
		                item_wearable:AddEffects(EF_NODRAW)
		                --print("Hidden",item_wearable:GetModelName(),name)

		                -- Frankestein the attachment   
		                local point = level_table["Point"]
		                local attach = unit:ScriptLookupAttachment(point)
		                
		                local new_prop = Entities:CreateByClassname("prop_dynamic")
		                
		                new_prop:SetModel(model)
		                local scale = tonumber(level_table["Scale"]) or unit:GetModelScale()
		                new_prop:SetModelScale(scale)		                
		                
		                -- Angles
		                local pitch = tonumber(level_table["Pitch"])
		                local yaw   = tonumber(level_table["Yaw"])
		                local roll  = tonumber(level_table["Roll"])

		                local angles = unit:GetAttachmentAngles(attach)

		                angles = angles + Vector(pitch, yaw, roll)

		                new_prop:SetAngles(angles.x,angles.y,angles.z)       

		                -- Position	                
		                local frontOffset = tonumber(level_table["Front"])
		                local rightOffset = tonumber(level_table["Right"])
		                local upOffset    = tonumber(level_table["Up"])
		          
		                local attach_pos = unit:GetAttachmentOrigin(attach)
		                local forward = frontOffset * --[[RotatePosition(Vector(0,0,0), QAngle(0,angles.y,0), Vector(1,0,0))]] (unit:GetForwardVector())
		                local right = rightOffset * --[[RotatePosition(Vector(0,0,0), QAngle(0,-90,0), forward)]] (unit:GetRightVector())

		                attach_pos = attach_pos + forward - right
		                attach_pos.z = unit:GetAbsOrigin().z + upOffset

		                new_prop:SetAbsOrigin(attach_pos)

		                -- Particle
		                local particleName = level_table["Particle"]
		                if particleName then
		                	local attach_fx = level_table["Attach_FX"]
		                	new_prop.fx = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, unit)
		                	if attach_fx then
			                	ParticleManager:SetParticleControlEnt(new_prop.fx, 0, new_prop, PATTACH_POINT_FOLLOW, attach_fx, new_prop:GetAbsOrigin(), true)
			                	ParticleManager:SetParticleControlEnt(new_prop.fx, 1, new_prop, PATTACH_POINT_FOLLOW, attach_fx, new_prop:GetAbsOrigin(), true)
			                end
			            end

			            -- Attach and store it
		                new_prop:SetParent(unit, point)

		                unit.prop_wearables[name] = new_prop
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


-- Go through all the ugprades of the player and add them to a unit
function PMP:ApplyAllUpgrades(playerID, unit)
	local upgrades = PMP:GetUpgradeList(playerID)

	for name,level in pairs(upgrades) do
		if level ~= 0 then
			PMP:ApplyUpgrade(unit, name, level)
		end
	end
end


function PMP:PrintUpgrades( playerID )
	local upgrades = PMP:GetUpgradeList(playerID)
	DeepPrintTable(upgrades)
end