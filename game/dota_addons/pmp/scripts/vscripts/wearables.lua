function ChangeWearableInSlot( unit, slotName, modelName )
    
    local db = Attachments:GetAttachmentDatabase()
    local wearables = GetWearablesForSlot(slotName)
    local unitModel = unit:GetModelName()
    local attachPoint = wearables["attach_points"][unitModel]

    -- Find if we can do a direct SetModel of the default item_wearable handle
    if db[unitModel] and db[unitModel][modelName] then
        --print("Perform direct SetModel",unit:GetModelName(),modelName,slotName)
        
        ClearPropWearableSlot(unit, slotName)
        SwapWearableInSlot(unit, modelName, slotName)
        return
    -- Create an Attachment
    else
        --print("Create Attachment",unit:GetModelName(),attachPoint,modelName,slotName)
        
        ClearPropWearableSlot(unit, slotName)
        HideWearableInSlot(unit, slotName)
        SetDefaultWearableInSlot(unit, slotName)

        local new_prop
        if attachPoint then
            new_prop = Attachments:AttachProp(unit, attachPoint, modelName)
        end

        -- If no attachment can be found on the database, try to set model
        if not new_prop then
            SwapWearableInSlot(unit, modelName, slotName)
        end
        unit.prop_wearables[slotName] = new_prop or unit.prop_wearables[slotName]
    end
end

---------------------------------

function SwapWearableInSlot( unit, modelName, slotName )
    -- Get original wearable and change its model
    local item_wearable = GetOriginalWearableInSlot(unit, slotName)
    if not item_wearable then
        return
    end

    item_wearable:SetModel(modelName)

    if item_wearable.hidden then
        item_wearable:RemoveEffects(EF_NODRAW)
        item_wearable.hidden = false
    end

    -- Clear any prop wearable the unit might have in this slot
    ClearPropWearableSlot(unit, slot)
end

function HideWearableInSlot( unit, slotName )
    local item_wearable = GetOriginalWearableInSlot(unit, slotName)
    if item_wearable then
        item_wearable:AddEffects(EF_NODRAW)
        item_wearable.hidden = true
    end
end

function HideUnit( unit )
    unit:AddNoDraw()
    ApplyModifier(unit, "modifier_hide")
    if not unit.prop_wearables then return end
     
    for k,v in pairs(unit.prop_wearables) do
        if v and IsValidEntity(v) then
            v:AddEffects(EF_NODRAW)
        end
    end
end

function RevealUnit( unit )
    unit:RemoveNoDraw()
    unit:RemoveModifierByName("modifier_hide")
    if not unit.prop_wearables then return end  
    
    for k,v in pairs(unit.prop_wearables) do
        if v and IsValidEntity(v) then
            v:RemoveEffects(EF_NODRAW)
        end
    end
end

function SetDefaultWearableInSlot( unit, slotName )
    local default_wearable_name = GetDefaultWearableNameForSlot(unit, slotName)
    local item_wearable = GetOriginalWearableInSlot(unit, slotName)

    if item_wearable and default_wearable_name then
        item_wearable:SetModel(default_wearable_name)
    end
end

function HidePropWearableSlot( unit, slot )
    if unit.prop_wearables[slot] and IsValidEntity(unit.prop_wearables[slot]) then 
        unit.prop_wearables[slot]:AddEffects(EF_NODRAW)
    end
end

function ClearPropWearableSlot( unit, slot )
    if not unit.prop_wearables then 
        unit.prop_wearables = {}
        return 
    end

    if unit.prop_wearables[slot] and IsValidEntity(unit.prop_wearables[slot]) then 
        if unit.prop_wearables[slot].fx then
            ParticleManager:DestroyParticle(unit.prop_wearables[slot].fx, true)
        end
        --print("Clearing",unit.prop_wearables[slot],unit.prop_wearables[slot]:GetModelName())
        UTIL_Remove(unit.prop_wearables[slot])
    end
end

function ClearPropWearables( unit )
    if not unit.prop_wearables then return end
    for k,v in pairs(unit.prop_wearables) do
        ClearPropWearableSlot(unit, k)
    end
end

function HidePropWearables( unit )
    if not unit.prop_wearables then return end
    for slot,prop in pairs(unit.prop_wearables) do
        if IsValidEntity(prop) then
            prop:AddEffects(EF_NODRAW)
        end
    end
end

function ShowPropWearables( unit )
    if not unit.prop_wearables then return end
    for slot,prop in pairs(unit.prop_wearables) do
        if IsValidEntity(prop) then
            prop:RemoveEffects(EF_NODRAW)
        end
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

function GetOriginalWearableInSlot(unit, slotName)
    -- If it was already stored, return the reference directly
    if not unit.item_wearables then unit.item_wearables = {} end
    if unit.item_wearables[slotName] then
        return unit.item_wearables[slotName]

    else       
        local default_wearable_name = GetDefaultWearableNameForSlot(unit, slotName)
        local target_wearable = GetWearable(unit, default_wearable_name)

        -- Keep a reference
        unit.item_wearables[slotName] = target_wearable

        return target_wearable
    end
end

function GetDefaultWearableNameForSlot(unit, slotName)
    local wearables = GetWearablesForSlot(slotName)
    local table_slot = wearables['defaults']
    local default_wearable_name = table_slot[unit:GetModelName()]

    return default_wearable_name
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

function GetWearablesForSlot(slotName)
    return HATS[slotName]
end

----------------------------------------------
-- DEPRECATED
-- Create a new prop_dynamic wearable in this slot name
function AttachWearableInSlot( unit, model_table, slot )

    -- Model of choice
    local point = model_table["Point"]
    local modelName = model_table["Model"]
    local modelScale = tonumber(model_table["Scale"]) or GetOriginalModelScale(unit)
    local animation = model_table["Animation"] or ""

    -- Adjust the modelScale
    local unitModelScale = unit:GetModelScale() 
    unit:SetModelScale(GetOriginalModelScale(unit))

    -- Clear any prop wearable the unit might have in this slot
    ClearPropWearableSlot(unit, slot)

    -- Get original wearable and hide it
    local item_wearable = GetOriginalWearableInSlot(unit, slot)
    if not item_wearable then
        return
    else
        local defaultModelName = GetDefaultWearableNameForSlot(unit, slot)
        item_wearable:AddEffects(EF_NODRAW)
        item_wearable:SetModel(defaultModelName)
        item_wearable.hidden = true
    end
    
    -- Model offsets
    local pitch = tonumber(model_table["Pitch"])
    local yaw   = tonumber(model_table["Yaw"])
    local roll  = tonumber(model_table["Roll"])

    local right = tonumber(model_table["Right"])
    local front = tonumber(model_table["Front"])
    local up    = tonumber(model_table["Up"])

     -- "Euler Angle Version of Quaternion" - BMD Magic
    local QX    = tonumber(model_table["QX"])
    local QY    = tonumber(model_table["QY"])
    local QZ    = tonumber(model_table["QZ"])
    local angleSpace = QAngle(QX, QY, QZ)

    local offset = RotatePosition(Vector(0,0,0), RotationDelta(angleSpace, QAngle(0,0,0)), Vector(right,front,up))

    -- Frankestein the attachment
    local new_prop = SpawnEntityFromTableSynchronous("prop_dynamic", {model = modelName, scale = modelScale, DefaultAnim = animation })
    local attach = unit:ScriptLookupAttachment(point)
    local angles = unit:GetAttachmentAngles(attach) + Vector(pitch, yaw, roll)  
    local attach_pos = unit:GetAttachmentOrigin(attach) + RotatePosition(Vector(0,0,0), QAngle(angles.x,angles.y,angles.z), offset)

    if unit == GetMainSelectedEntity(0) then
        print('angleSpace = QAngle(' .. angles.x .. ', ' .. angles.y .. ', ' .. angles.z .. ')')
    end

    new_prop:SetAbsOrigin(attach_pos)
    new_prop:SetAngles(angles.x,angles.y,angles.z)
    new_prop:SetParent(unit, point)

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

     -- Store it
    unit.prop_wearables[slot] = new_prop
    

    --
    unit:SetModelScale(unitModelScale)

end

-- Swaps a target model for another
function SwapWearable( unit, target_model, new_model )
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