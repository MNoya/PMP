-- Each player should store its current cosmetics to apply on peons
-- hero.Wearables = {}
-- hero.Wearables["weapon"] = "some_model_path"
function SwapWearable( cmd, target_model, new_model )
    local unit = GetMainSelectedEntity(0)
    print(unit,target_model, new_model)

    local wearable = unit:FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            if wearable:GetModelName() == target_model then
                wearable:SetModel( new_model )
                return
            end
        end
        wearable = wearable:NextMovePeer()
    end
end

-- Returns a wearable handle if its the passed target_model
function GetWearable( unit, target_model )
    local wearable = unit:FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            if wearable:GetModelName() == target_model then
                return wearable
            end
        end
        wearable = wearable:NextMovePeer()
    end
    return false
end

function HideWearable( unit, target_model )
    local wearable = unit:FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            if wearable:GetModelName() == target_model then
                wearable:AddEffects(EF_NODRAW)
                return
            end
        end
        wearable = wearable:NextMovePeer()
    end
end

function ShowWearable( unit, target_model )
    local wearable = unit:FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            if wearable:GetModelName() == target_model then
                wearable:RemoveEffects(EF_NODRAW)
                return
            end
        end
        wearable = wearable:NextMovePeer()
    end
end

function ClearPropWearableSlot( unit, slot )
    if not unit.prop_wearables then return end
    if unit.prop_wearables[slot] then 
        if unit.prop_wearables[slot].fx then
            ParticleManager:DestroyParticle(unit.prop_wearables[slot].fx, true)
        end
        UTIL_Remove(unit.prop_wearables[slot])
    end
end

function ClearPropWearables( unit )
    if not unit.prop_wearables then return end
    for k,v in pairs(unit.prop_wearables) do
        ClearPropWearableSlot(unit, k)
    end
end

function PrintWearables( unit )
    print("---------------------")
    print("Wearable List of "..unit:GetUnitName())
    print("Main Model: "..unit:GetModelName())
    local wearable = unit:FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            local model_name = wearable:GetModelName()
            if model_name ~= "" then print(model_name) end
        end
        wearable = wearable:NextMovePeer()
    end
end


-------------------------------------------

function GetOriginalWearableInSlot(unit, name)
    -- If it was already stored, return the reference directly
    if not unit.item_wearables then unit.item_wearables = {} end
    if unit.item_wearables[name] then
        return unit.item_wearables[name]

    else       
        local default_wearable_name = GetDefaultWearableNameForSlot(unit, name)
        local target_wearable = GetWearable(unit, default_wearable_name)

        -- Keep a reference
        unit.item_wearables[name] = target_wearable

        return target_wearable
    end
end

function GetDefaultWearableNameForSlot(unit, name)
    local wearables = GetWearablesForUnit(unit)
    if not wearables then
        print("No wearables for ",unit:GetUnitName()," in slot ",name)
        return
    end

    local table_slot = wearables[name]
    local default_wearable_name = table_slot["Default"]

    return default_wearable_name
end

function GetWearablesForUnit(unit)
    HATS = LoadKeyValues("scripts/kv/wearables.kv") --Reload for tests
    return HATS[unit:GetUnitName()]
end


--[[

function PMP:GetWearableInfoForCurrentLevel( playerID, slotName ) --Returns the subtable to attach next

-- There are 2 types of changes
-- When a unit spawns, it needs to go from 0 to (Current Level of each wearable upgrade)
-- When upgrade finishes, all units need to go to a particular level (we want to be able to go from level 3 to 15 for testing purposes)

-- This returns the units currently attached item for that slot
function PMP:GetWearableInSlot( unit, slotName )

-- We need a list of defaults to read from
-- Keep a reference to the original wearable for each slot, to not have to find it every time
function PMP:GetOriginalWearableInSlot( unit, slotName )

-- When changing, there are 2 possible types of attachments
-- ModelChange and ModelAttach
-- The first one is straightforward, it only needs to find the current model and SetModel
-- The second one will need: Pitch/Yaw/Roll Angles, Front/Right/Up Offsets and attach_point

-- Layout - Could be a lua table instead, to be able to change it with script_reload?
-- Try to use all the default model changes first, and hard-attachments for the later levels
"Wearables"
{
    "peon"
    {
        "weapon"
        {
            "Default" "axe_weapon.vmdl"

            "1"
            {
                "Model" "axe_weapon2.vmdl"
                "Type"  "Change"
            }

            "2"
            {
                "Model" "void_hammer.vmdl"
                "Type"  "Attach"
                "Point" "attach_left"
                
                -- Angles
                "pitch" "0"
                "yaw"   "90"
                "roll"  "0"  
                
                -- Offset
                "front" "10"
                "right" "30"
                "up"    "128"
            }
        }
    }
}

Command: test (slot) (level) --Internally, get the cmdPlayer and race
function PMP:SetWearableSlotLevel( playerID, slotName, level )

    -- Go to each unit calling AdjustWearables

end

-- Called from SetWearableSlotLevel on all units, and when a unit spawns
function PMP:AdjustWearables( unit )

    local slot = "weapon" -- Iterate on each one

    -- Get the currently equiped wearable
    local wearable = PMP:GetUnitWearableInSlot(unit, slot)

    -- If its a prop_dynamic, remove it... or try to reposition it
    if wearable:GetClassname() == "prop_dynamic" then
        UTIL_Remove(wearable)
    
    else
        -- If its a model, hide it with AddEffects. 
        wearable:AddEffects(EF_NODRAW)
    end


    local next_wearable_table = PMP:GetWearableInfoForCurrentLevel(unit:GetPlayerOwnerID(), slot)
    if next_wearable_table["Type"] == "Change" then
        local next_wear = PMP:GetOriginalWearableInSlot(unit, slot)
        next_wear:SetModel(next_wearable_table["Model"])
        next_wear:RemoveEffects(EF_NODRAW)
    else
        print("Complex attach required for ",next_wearable_table["Model"])

    end
end]]