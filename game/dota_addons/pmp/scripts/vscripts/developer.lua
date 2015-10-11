CHEAT_CODES = {
    ["greedisgood"] = function(...) PMP:GreedIsGood(...) end,  -- Gives X gold and lumber
    ["createunits"] = function(...) PMP:CreateUnits(...) end,  -- Creates 'name' units around the currently selected unit, with optional num and neutral team
    ["pimp"]        = function(...) PMP:SetUpgrade(...) end,    -- upgrade [weapon/helm/armor/wings/health/critical_strike/stun_hit/poisoned_weapons/pulverize/dodge/spiked_armor] [level]
    ["reset"]       = function(...) PMP:ResetAllUpgrades(...) end,
    ["freeze"]      = function(...) PMP:Freeze(...) end,
    ["gg"]          = function(...) PMP:GG(...) end
}

PLAYER_COMMANDS = {
    ["music"]       = function(...) PMP:Music(...) end,
    ["stopmusic"]   = function(...) PMP:StopMusic(...) end
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
    if CHEAT_CODES[command] and Convars:GetBool('developer') then
        --print('Command:',command, "Player:",playerID, "Parameters",input[2], input[3], input[4])
        CHEAT_CODES[command](playerID, input[2], input[3], input[4])
    
    elseif PLAYER_COMMANDS[command] then
        PLAYER_COMMANDS[command](playerID)
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
            unit:SetControllableByPlayer(pID, true)
            unit:SetMana(unit:GetMaxMana())

            if bEnemy then 
                unit:SetTeam(DOTA_TEAM_NEUTRALS)
            else
                unit:SetOwner(hero)
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

function PMP:Music(pID)
    local player = PlayerResource:GetPlayer(pID)
    
    if player and not GameRules.PlayingMusic[pID] then
        GameRules.PlayingMusic[pID] = true
        EmitSoundOnClient("PMP.PowerOfTheHorde", player)
        
        Timers:CreateTimer(281, function() 
            local player = PlayerResource:GetPlayer(pID)
            if player and GameRules.PlayingMusic[pID] then
                EmitSoundOnClient("PMP.PowerOfTheHorde", player)
                return 281
            else
                return
            end
        end)
    end
end

function PMP:StopMusic(pID)
    local player = PlayerResource:GetPlayer(pID)
    
    if player and GameRules.PlayingMusic[pID] then
        GameRules.PlayingMusic[pID] = false
        StopSoundOn("PMP.PowerOfTheHorde", player)
    end
end

function PMP:Freeze()
    GameRules.freeze = not GameRules.freeze

    local units = GetPlayerUnits(0)
    if GameRules.freeze then
        for k,unit in pairs(units) do
            unit:AddNewModifier(unit, nil, "modifier_faceless_void_chronosphere_freeze", {})
            unit:SetForwardVector(Vector(0,-1,0))
        end
    else
        for k,unit in pairs(units) do
            unit:RemoveModifierByName("modifier_faceless_void_chronosphere_freeze")
        end
    end
end

function PMP:GG()
    local winningTeam = DOTA_TEAM_CUSTOM_3--PMP:GetWinningTeam()
    local winners = {}

    CustomGameEventManager:Send_ServerToAllClients("gg", {})

    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                local showcase = GetPlayerShop(playerID)
                showcase:SetDayTimeVisionRange(1800)
                showcase:SetNightTimeVisionRange(1800)
                showcase:SetHullRadius(0)
                FindClearSpaceForUnit(showcase, Vector( (playerID * 150)-750,-3900,128), true)
                showcase:RemoveNoDraw()
                showcase:RemoveModifierByName("modifier_hidden")
                showcase:SetAngles(0,90,0)
                if showcase:GetTeamNumber() == winningTeam then
                    table.insert(winners, showcase)
                end
            end
        end
    end

    for k,unit in pairs(winners) do
        unit:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
        unit:RemoveModifierByName("modifier_building")
        unit:SetBaseMoveSpeed(400)
        unit:MoveToPosition(Vector((k*150)-150,-3500,128))
        Timers:CreateTimer(1,function()
            if unit:IsIdle() then
                unit:MoveToPosition(Vector((k*150)-150,-3499,128))
                local race = GetRace(unit)
                local animation = endAnimations[race]
                if race == "night_elf" then
                    StartAnimation(unit, {duration=10, activity=animation, rate=1, translate="whats_that"})
                else
                    StartAnimation(unit, {duration=10, activity=animation, rate=1})
                end
            else
                return 0.5
            end
        end)
    end
end

endAnimations = {
    ["undead"]  = ACT_DOTA_VICTORY,
    ["peon"]    = ACT_DOTA_VICTORY,
    ["human"]   = ACT_DOTA_VICTORY,
    ["skeleton"]    = ACT_DOTA_DIE_SPECIAL,
    ["night_elf"]   = ACT_DOTA_TAUNT,
    ["blood_elf"]   = ACT_DOTA_VICTORY,
    ["goblin"]  = ACT_DOTA_VICTORY,
    ["treant"]  = ACT_DOTA_CAST_ABILITY_5,
}