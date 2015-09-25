function PMP:FilterExecuteOrder( filterTable )
    --[[
    print("-----------------------------------------")
    for k, v in pairs( filterTable ) do
        print("Order: " .. k .. " " .. tostring(v) )
    end
    ]]

    local units = filterTable["units"]
    local order_type = filterTable["order_type"]
    local issuer = filterTable["issuer_player_id_const"]
    local abilityIndex = filterTable["entindex_ability"]
    local targetIndex = filterTable["entindex_target"]
    local x = tonumber(filterTable["position_x"])
    local y = tonumber(filterTable["position_y"])
    local z = tonumber(filterTable["position_z"])
    local point = Vector(x,y,z)

    local queue = filterTable["queue"]
    if queue == 1 then 
        queue = true
    else
        Queue = queue
    end

    -- Skip Prevents order loops
    local unit = EntIndexToHScript(units["0"])
    if unit and unit.skip then
        if DEBUG then print("Skip") end
            unit.skip = false
        return true
    else
        if DEBUG then print("Execute this order") end
    end

    local numUnits = 0
    local numBuildings = 0
    if units then
        for n,unit_index in pairs(units) do
            local unit = EntIndexToHScript(unit_index)
            if unit and IsValidEntity(unit) then
                if not unit:IsBuilding() and not IsCustomBuilding(unit) then
                    numUnits = numUnits + 1
                elseif unit:IsBuilding() or IsCustomBuilding(unit) then
                    numBuildings = numBuildings + 1
                end
            end
        end
    end

    ------------------------------------------------
    --           Grid Unit Formation              --
    ------------------------------------------------
    if (order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or order_type == DOTA_UNIT_ORDER_ATTACK_MOVE) and numUnits > 1 then

        local SQUARE_FACTOR = 1.3 --1 is a perfect square, higher numbers will increase the units per row

        local navPoints = {}
        local first_unit = EntIndexToHScript(units["0"])
        local origin = first_unit:GetAbsOrigin()

        local point = Vector(x,y,z) -- initial goal

        local unitsPerRow = math.floor(math.sqrt(numUnits/SQUARE_FACTOR))
        local unitsPerColumn = math.floor((numUnits / unitsPerRow))
        local remainder = numUnits - (unitsPerRow*unitsPerColumn) 
        --print(numUnits.." units = "..unitsPerRow.." rows of "..unitsPerColumn.." with a remainder of "..remainder)

        local start = (unitsPerColumn-1)* -.5

        local curX = start
        local curY = 0

        local offsetX = UNIT_FORMATION_DISTANCE
        local offsetY = UNIT_FORMATION_DISTANCE
        local forward = (point-origin):Normalized()
        local right = RotatePosition(Vector(0,0,0), QAngle(0,90,0), forward)

        for i=1,unitsPerRow do
          for j=1,unitsPerColumn do
            --print ('grid point (' .. curX .. ', ' .. curY .. ')')
            local newPoint = point + (curX * offsetX * right) + (curY * offsetY * forward)
			if DEBUG then 
                DebugDrawCircle(newPoint, Vector(0,0,0), 255, 25, true, 5)
                DebugDrawText(newPoint, curX .. ', ' .. curY, true, 10) 
            end
            navPoints[#navPoints+1] = newPoint
            curX = curX + 1
          end
          curX = start
          curY = curY - 1
        end

        local curX = ((remainder-1) * -.5)

        for i=1,remainder do 
			--print ('grid point (' .. curX .. ', ' .. curY .. ')')
			local newPoint = point + (curX * offsetX * right) + (curY * offsetY * forward)
			navPoints[#navPoints+1] = newPoint
			curX = curX + 1
        end

        for i=1,#navPoints do 
            local point = navPoints[i]
            --print(i,navPoints[i])
        end

        -- Sort the units by distance to the nav points
        sortedUnits = {}
        for i=1,#navPoints do
            local point = navPoints[i]
            local closest_unit_index = GetClosestUnitToPoint(units, point)
            if closest_unit_index then
                --print("Closest to point is ",closest_unit_index," - inserting in table of sorted units")
                table.insert(sortedUnits, closest_unit_index)

                --print("Removing unit of index "..closest_unit_index.." from the table:")
                --DeepPrintTable(units)
                units = RemoveElementFromTable(units, closest_unit_index)
            end
        end

        -- Order each unit sorted to move to its respective Nav Point
        local n = 0
        for _,unit_index in pairs(sortedUnits) do
            local unit = EntIndexToHScript(unit_index)
            --print("Issuing a New Movement Order to unit index: ",unit_index)

            local pos = navPoints[tonumber(n)+1]
            --print("Unit Number "..n.." moving to ", pos)
            n = n+1

            -- Don't move aggresive with the Leader units
            if IsLeaderUnit(unit) then
                ExecuteOrderFromTable({ UnitIndex = unit_index, OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = pos, Queue = queue})
            else
                ExecuteOrderFromTable({ UnitIndex = unit_index, OrderType = order_type, Position = pos, Queue = queue})
            end
        end
        return false
    

    -- Move Flag
    elseif (order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION) then
        if unit and IsCityCenter(unit) then

            local event = { pID = issuer, mainSelected = unit:GetEntityIndex(), pos_x = x, pos_y = y, pos_z = z }
            PMP:OnBuildingRallyOrder( event )

            return false
        end

    elseif (unit and order_type == DOTA_UNIT_ORDER_ATTACK_TARGET and IsLeaderUnit(unit)) then
        return false
    end

    return true
end

function PMP:OnBuildingRallyOrder( event )
    -- Arguments
    local pID = event.pID
    local mainSelected = event.mainSelected
    local rally_type = event.rally_type
    local position = event.position
    if position then
        position = Vector(position["0"], position["1"], position["2"])
    else
        position = Vector(event.pos_x, event.pos_y, event.pos_z)
    end

    local building = EntIndexToHScript(mainSelected)
    local player = PlayerResource:GetPlayer(pID)

    -- Remove the old flag if there is one
    if building.flag then
        ParticleManager:DestroyParticle(building.flag, true)
    end

    if IsCityCenter(building) then
        EmitSoundOnClient("DOTA_Item.ObserverWard.Activate", player)

        -- Make a flag dummy on the position
        local teamNumber = building:GetTeamNumber()
        local color = TEAM_COLORS[teamNumber]
        building.flag = ParticleManager:CreateParticleForTeam("particles/custom/rally_flag.vpcf", PATTACH_CUSTOMORIGIN, building, teamNumber)
        ParticleManager:SetParticleControl(building.flag, 0, position) -- Position
        ParticleManager:SetParticleControl(building.flag, 1, building:GetAbsOrigin()) --Orientation
        ParticleManager:SetParticleControl(building.flag, 15, Vector(color[1], color[2], color[3])) --Color
        
        building.rally_point = position

        -- Extra X
        local Xparticle = ParticleManager:CreateParticleForTeam("particles/custom/x_marker.vpcf", PATTACH_CUSTOMORIGIN, building, teamNumber)
        ParticleManager:SetParticleControl(Xparticle, 0, position) --Orientation
        ParticleManager:SetParticleControl(Xparticle, 15, Vector(color[1], color[2], color[3])) --Color   
    end
end


------------------------------------------------
--              Utility functions             --
------------------------------------------------

-- Returns the closest unit to a point from a table of unit indexes
function GetClosestUnitToPoint( units_table, point )
    local closest_unit = units_table["0"]
    if not closest_unit then
        closest_unit = units_table[1]
    end
    if closest_unit then   
        local min_distance = (point - EntIndexToHScript(closest_unit):GetAbsOrigin()):Length()

        for _,unit_index in pairs(units_table) do
            local distance = (point - EntIndexToHScript(unit_index):GetAbsOrigin()):Length()
            if distance < min_distance then
                closest_unit = unit_index
                min_distance = distance
            end
        end
        return closest_unit
    else
        return nil
    end
end

-- Does awful table-recreation because table.remove refuses to work. Lua pls
function RemoveElementFromTable(table, element)
    local new_table = {}
    for k,v in pairs(table) do
        if v and v ~= element then
            new_table[#new_table+1] = v
        end
    end

    return new_table
end

ORDERS = {
    [0] = "DOTA_UNIT_ORDER_NONE",
    [1] = "DOTA_UNIT_ORDER_MOVE_TO_POSITION",
    [2] = "DOTA_UNIT_ORDER_MOVE_TO_TARGET",
    [3] = "DOTA_UNIT_ORDER_ATTACK_MOVE",
    [4] = "DOTA_UNIT_ORDER_ATTACK_TARGET",
    [5] = "DOTA_UNIT_ORDER_CAST_POSITION",
    [6] = "DOTA_UNIT_ORDER_CAST_TARGET",
    [7] = "DOTA_UNIT_ORDER_CAST_TARGET_TREE",
    [8] = "DOTA_UNIT_ORDER_CAST_NO_TARGET",
    [9] = "DOTA_UNIT_ORDER_CAST_TOGGLE",
    [10] = "DOTA_UNIT_ORDER_HOLD_POSITION",
    [11] = "DOTA_UNIT_ORDER_TRAIN_ABILITY",
    [12] = "DOTA_UNIT_ORDER_DROP_ITEM",
    [13] = "DOTA_UNIT_ORDER_GIVE_ITEM",
    [14] = "DOTA_UNIT_ORDER_PICKUP_ITEM",
    [15] = "DOTA_UNIT_ORDER_PICKUP_RUNE",
    [16] = "DOTA_UNIT_ORDER_PURCHASE_ITEM",
    [17] = "DOTA_UNIT_ORDER_SELL_ITEM",
    [18] = "DOTA_UNIT_ORDER_DISASSEMBLE_ITEM",
    [19] = "DOTA_UNIT_ORDER_MOVE_ITEM",
    [20] = "DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO",
    [21] = "DOTA_UNIT_ORDER_STOP",
    [22] = "DOTA_UNIT_ORDER_TAUNT",
    [23] = "DOTA_UNIT_ORDER_BUYBACK",
    [24] = "DOTA_UNIT_ORDER_GLYPH",
    [25] = "DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH",
    [26] = "DOTA_UNIT_ORDER_CAST_RUNE",
    [27] = "DOTA_UNIT_ORDER_PING_ABILITY",
    [28] = "DOTA_UNIT_ORDER_MOVE_TO_DIRECTION",
}