TRADER_THINK_TIME = 45
function StartThink( event )
    local trader = event.caster

    -- Keep reference
    GameRules.Trader = trader
    GameRules.TimesTraded = 0

    -- Keep track of nearby patrons
    trader.current_unit = {}
    trader.active_particle = {}

    local waypoints = CollectWayPoints()
    local wpNum = 1

    Timers:CreateTimer(TRADER_THINK_TIME, function()
        wpNum = wpNum+1
        if wpNum == 11 then wpNum = 1 end
        local nextWP = waypoints[wpNum]:GetAbsOrigin()
        --print("Trader moving to next WP:",wpNum,VectorString(nextWP))
        trader:MoveToPosition(nextWP)

        return TRADER_THINK_TIME
    end)

    --[[Timers:CreateTimer(1, function()
        for i=0,DOTA_TEAM_COUNT do
            AddFOWViewer ( i, trader:GetAbsOrigin(), 1000, 1.1, false)
        end
        return 1
    end)]]
end

function CollectWayPoints()

    local waypoint1 = Entities:FindByName(nil, "trader_wp_1")
    local waypoint2 = Entities:FindByName(nil, "trader_wp_2")
    local waypoint3 = Entities:FindByName(nil, "trader_wp_3")
    local waypoint4 = Entities:FindByName(nil, "trader_wp_4")
    local waypoint5 = Entities:FindByName(nil, "trader_wp_5")
    local waypoint6 = Entities:FindByName(nil, "trader_wp_6")
    local waypoint7 = Entities:FindByName(nil, "trader_wp_7")
    local waypoint8 = Entities:FindByName(nil, "trader_wp_8")
    local waypoint9 = Entities:FindByName(nil, "trader_wp_9")
    local waypoint10 = Entities:FindByName(nil, "trader_wp_10")

    local waypoints = { waypoint1, waypoint2, waypoint3, waypoint4, waypoint5, waypoint6, waypoint7, waypoint8, waypoint9, waypoint10 }

    return waypoints
end

------------------------------------------------

function PMP:OnTradeOrder( event )
    local pID = event.PlayerID
    local resource_type = event.Type
    local resource_needed = 100
    local resource_gain = 50

    local unitNearby = TraderHasNearbyPatronForPlayer(pID)
    if unitNearby then
        if resource_type == "lumber" then
            if PlayerHasEnoughGold(pID, resource_needed) then
                --print("Exchanging Gold -> Lumber")
                GameRules.TimesTraded = GameRules.TimesTraded + 1
                EmitSoundOnClient("General.Buy", PlayerResource:GetPlayer(pID))
                ModifyGold( pID, -resource_needed )
                ModifyLumber( pID, resource_gain )
                PopupLumber(unitNearby, resource_gain, unitNearby:GetTeamNumber())
            end

        elseif resource_type == "gold" then
            if PlayerHasEnoughLumber(pID, resource_needed) then
                --print("Exchanging Lumber -> Gold")
                GameRules.TimesTraded = GameRules.TimesTraded + 1
                EmitSoundOnClient("General.Buy", PlayerResource:GetPlayer(pID))
                ModifyLumber( pID, -resource_needed )
                ModifyGold( pID, resource_gain )
                PopupGoldGain(unitNearby, resource_gain, unitNearby:GetTeamNumber())
            end
        end
    else
        SendErrorMessage(pID, "#error_no_buyers_found")
    end
end

function TraderHasNearbyPatronForPlayer( pID )
    local trader = GameRules.Trader

    if trader.current_unit[pID] then
        local unit = trader.current_unit[pID]
        --Double check
        if IsValidAlive(unit) and trader:GetRangeToUnit(unit) <= 900 then
            return unit
        else
            return false
        end
    end
end

------------------------------------------------

-- The trader will try to assign a valid buyer to each valid player unit nearby
function CheckUnitsInRadius( event )
    local trader = event.caster
    local ability = event.ability

    for playerID=0,DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            local player = PlayerResource:GetPlayer(playerID)
            local current_unit = trader.current_unit[playerID]

            -- If there is a unit acquired, check if its still valid
            if IsValidAlive(current_unit) then
                
                -- Break out of range
                if trader:GetRangeToUnit(current_unit) > 900 then
                    if trader.active_particle[playerID] then
                        ParticleManager:DestroyParticle(trader.active_particle[playerID], true)
                    end
                    trader.current_unit[playerID] = nil
                      
                    return
                end
            else
                -- Find nearby units in radius
                local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, trader:GetAbsOrigin(), nil, 900, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)

                -- If a unit is found, set that unit as valid for trade
                if #units > 0 then
                    local unit = units[1]
                    SetCurrentTradingUnitForPlayer(playerID, trader, unit)
                end
            end
        end
    end
end

function SetCurrentTradingUnitForPlayer( pID, shop, unit )
    local player = PlayerResource:GetPlayer(pID)

    -- Set the current unit of this shop for this player
    shop.current_unit[pID] = unit
    
    if shop.active_particle[pID] then
        ParticleManager:DestroyParticle(shop.active_particle[pID], true)
    end
    shop.active_particle[pID] = ParticleManager:CreateParticleForPlayer("particles/custom/shop_arrow.vpcf", PATTACH_OVERHEAD_FOLLOW, unit, player)

    ParticleManager:SetParticleControl(shop.active_particle[pID], 0, unit:GetAbsOrigin())
end