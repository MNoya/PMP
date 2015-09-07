CHEAT_CODES = {
    ["greedisgood"] = function(...) PMP:GreedIsGood(...) end,  -- Gives X gold and lumber
    ["createunits"] = function(...) PMP:CreateUnits(...) end,  -- Creates 'name' units around the currently selected unit, with optional num and neutral team
    ["music"]       = function(...) PMP:Music(...) end,
    ["stopmusic"]   = function(...) PMP:StopMusic(...) end,
    ["pimp"]        = function(...) PMP:SetUpgrade(...) end,    -- upgrade [weapon/helm/armor/wings/health/critical_strike/stun_hit/poisoned_weapons/pulverize/dodge/spiked_armor] [level]
    
    --reset
    --bot race
    --set type model x y z
}

-- A player has typed something into the chat
function PMP:OnPlayerChat(keys)
    local text = keys.text
    local userID = keys.userid
    local playerID = self.vUserIds[userID]:GetPlayerID()

    -- Handle '-command'
    if StringStartsWith(text, "-") then
        text = string.sub(text, 2, string.len(text))
    end

    local input = split(text)
    local command = input[1]
    if CHEAT_CODES[command] then
        print('Command:',command, "Player:",playerID, "Parameters",input[2], input[3], input[4])
        CHEAT_CODES[command](playerID, input[2], input[3], input[4])
    end        
end

function PMP:GreedIsGood(pID, value)
    if not value then value = 500 end
    
    ModifyGold(pID, tonumber(value))
    ModifyLumber(pID, tonumber(value))
    
    GameRules:SendCustomMessage("Cheat enabled!", 0, 0)
end

function PMP:CreateUnits(pID, unitName, numUnits, bEnemy)
    local pos = GetMainSelectedEntity(pID):GetAbsOrigin()
    local hero = PlayerResource:GetSelectedHeroEntity(pID)

     -- Handle possible unit issues
    numUnits = numUnits or 1
    if not GameRules.UnitKV[unitName] then
        Say(nil,"["..unitName.."] <font color='#ff0000'> is not a valid unit name!</font>", false)
        return
    end

    local gridPoints = GetGridAroundPoint(numUnits, pos)

    PrecacheUnitByNameAsync(unitName, function()
        for i=1,numUnits do
            local unit = CreateUnitByName(unitName, gridPoints[i], true, hero, hero, hero:GetTeamNumber())
            unit:SetOwner(hero)
            unit:SetControllableByPlayer(pID, true)
            unit:SetMana(unit:GetMaxMana())

            if bEnemy then 
                unit:SetTeam(DOTA_TEAM_NEUTRALS)
            else
                table.insert(hero.units, unit)
            end

            FindClearSpaceForUnit(unit, gridPoints[i], true)
            unit:Hold()         
        end
    end, pID)
end

function GetGridAroundPoint( numUnits, point )
    local navPoints = {}  

    local unitsPerRow = math.floor(math.sqrt(numUnits))
    local unitsPerColumn = math.floor((numUnits / unitsPerRow))
    local remainder = numUnits - (unitsPerRow*unitsPerColumn) 

    local forward = point:Normalized()
    local right = RotatePosition(Vector(0,0,0), QAngle(0,90,0), forward)

    local start = (unitsPerColumn-1)* -.5

    local curX = start
    local curY = 0

    local offsetX = 100
    local offsetY = 100

    for i=1,unitsPerRow do
      for j=1,unitsPerColumn do
        local newPoint = point + (curX * offsetX * right) + (curY * offsetY * forward)
        navPoints[#navPoints+1] = newPoint
        curX = curX + 1
      end
      curX = start
      curY = curY - 1
    end

    local curX = ((remainder-1) * -.5)

    for i=1,remainder do 
        local newPoint = point + (curX * offsetX * right) + (curY * offsetY * forward)
        navPoints[#navPoints+1] = newPoint
        curX = curX + 1
    end

    return navPoints
end

function PMP:Music()
    print("Play Music")
    SendToConsole("stopsound")

    Timers:CreateTimer(1,function()
        EmitGlobalSound("PMP.PowerOfTheHorde")
    end)
end

function PMP:StopMusic()
    SendToConsole("stopsound")
end