TRADER_THINK_TIME = 45
function StartThink( event )
    local trader = event.caster

    local waypoints = CollectWayPoints()
    local wpNum = 1

    Timers:CreateTimer(TRADER_THINK_TIME, function()
        wpNum = wpNum+1
        if wpNum == 11 then wpNum = 1 end
        local nextWP = waypoints[wpNum]:GetAbsOrigin()
        print("Trader moving to next WP:",wpNum,VectorString(nextWP))
        trader:MoveToPosition(nextWP)

        return TRADER_THINK_TIME
    end)

    Timers:CreateTimer(1, function()
        for i=0,DOTA_TEAM_COUNT do
            AddFOWViewer ( DOTA_TEAM_GOODGUYS, trader:GetAbsOrigin(), 1000, 1.1, false)
        end
        return 1
    end)
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