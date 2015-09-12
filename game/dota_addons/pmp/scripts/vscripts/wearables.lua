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

function SwapWearableInSlot( unit, model_table, slot )

    -- Get original wearable and change its model
    local item_wearable = GetOriginalWearableInSlot(unit, slot)
    if not item_wearable then
        return
    end

    local modelName = model_table["Model"]
    item_wearable:SetModel(modelName)
    item_wearable:RemoveEffects(EF_NODRAW)

    -- Clear any prop wearable the unit might have in this slot
    ClearPropWearableSlot(unit, slot)
end

-- Create a new prop_dynamic wearable in this slot name
function AttachWearableInSlot( unit, model_table, slot, delay )

    -- Clear any prop wearable the unit might have in this slot
    ClearPropWearableSlot(unit, slot)

    -- Get original wearable and hide it
    local item_wearable = GetOriginalWearableInSlot(unit, slot)
    if not item_wearable then
        return
    end
    
    local modelName = model_table["Model"]
    item_wearable:AddEffects(EF_NODRAW)
    item_wearable:SetModel(modelName) --Just to update portrait

    -- Frankestein the attachment   
    local point = model_table["Point"]
    local attach = unit:ScriptLookupAttachment(point)
    
    local new_prop = Entities:CreateByClassname("prop_dynamic")
    
    new_prop:SetModel(modelName)
    local scale = tonumber(model_table["Scale"]) or unit:GetModelScale()
    new_prop:SetModelScale(scale)                       
    
    -- Angles
    local pitch = tonumber(model_table["Pitch"])
    local yaw   = tonumber(model_table["Yaw"])
    local roll  = tonumber(model_table["Roll"])

    local angles = unit:GetAttachmentAngles(attach) + Vector(pitch, yaw, roll)

    new_prop:SetAngles(angles.x,angles.y,angles.z)       

    -- Position
    local attach_pos = unit:GetAttachmentOrigin(attach)

    local frontOffset = tonumber(model_table["Front"])
    local rightOffset = tonumber(model_table["Right"])
    local upOffset    = tonumber(model_table["Up"])  
    
    --[[ Old method:
    local forward = frontOffset *  (unit:GetForwardVector())
    local right = rightOffset * (unit:GetRightVector())

    attach_pos = attach_pos + forward - right
    attach_pos.z = unit:GetAbsOrigin().z + upOffset]]

    local offset = Vector(frontOffset, rightOffset, upOffset)
    local delta = RotationDelta(QAngle(0,0,0), QAngle(angles.x,angles.y,angles.z))
    attach_pos = attach_pos + RotatePosition(Vector(0,0,0), delta, offset)

    new_prop:SetAbsOrigin(attach_pos)

    -- Particle
    local particleName = model_table["Particle"]
    if particleName then
        local attach_fx = model_table["Attach_FX"]
        if attach_fx then            
            new_prop.fx = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, unit)
            if attach_fx then
                ParticleManager:SetParticleControlEnt(new_prop.fx, 0, new_prop, PATTACH_POINT_FOLLOW, attach_fx, new_prop:GetAbsOrigin(), true)
                ParticleManager:SetParticleControlEnt(new_prop.fx, 1, new_prop, PATTACH_POINT_FOLLOW, attach_fx, new_prop:GetAbsOrigin(), true)
                ParticleManager:SetParticleControlEnt(new_prop.fx, 2, new_prop, PATTACH_POINT_FOLLOW, attach_fx, new_prop:GetAbsOrigin(), true)
            end
        end
    end

    -- Attach and store it
    new_prop:SetParent(unit, point)

    unit.prop_wearables[slot] = new_prop
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