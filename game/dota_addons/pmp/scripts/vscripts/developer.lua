CHEAT_CODES = {
    ["greedisgood"] = function(...) PMP:GreedIsGood(...) end,  -- Gives X gold and lumber
    ["createunits"] = function(...) PMP:CreateUnits(...) end,  -- Creates 'name' units around the currently selected unit, with optional num and neutral team
    ["pimp"]        = function(...) PMP:SetUpgrade(...) end,    -- upgrade [weapon/helm/armor/wings/health/critical_strike/stun_hit/poisoned_weapons/pulverize/dodge/spiked_armor] [level]
    ["reset"]       = function(...) PMP:ResetAllUpgrades(...) end,
    ["freeze"]      = function(...) PMP:Freeze(...) end,
    ["gg"]          = function(...) PMP:GG(...) end,
    ["boss"]        = function(...) PMP:SpawnBoss(...) end,
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

function PMP:GreedIsGood(playerID, value)
    if not value then value = 500 end
    
    for pID=0,DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:IsValidPlayerID(pID) then
            ModifyGold(pID, tonumber(value))
            ModifyLumber(pID, tonumber(value))
        end
    end    
    
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
    else
        print(player,GameRules.PlayingMusic[pID])
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

function PMP:GG(winningTeam)
    if winningTeam == 0 then winningTeam=DOTA_TEAM_GOODGUYS end
    print(winningTeam," is the Winner")
    GameRules.Winner = winningTeam

    Timers:CreateTimer(3, function()
        GameRules:SetGameWinner(winningTeam)
    end)

    -- Announce victory
    local soundVictory
    if GetMapName() == "free_for_all" then
        -- Find out the player
        local playerID = 0
        for pID = 0,DOTA_MAX_TEAM_PLAYERS do
            if PlayerResource:IsValidPlayerID(pID) and PlayerResource:GetTeam(pID) == winningTeam then
                playerID = pID
            end
        end
        soundVictory = "Announcer.Player.Victory."..playerID+1
    else
        -- Victory to that team
        soundVictory = "Announcer.Team.Victory."..TEAM_NUMER_TO_COLOR[winningTeam]
    end

    EmitGlobalSound(soundVictory)

    -- Change the camera
    CustomGameEventManager:Send_ServerToAllClients("gg", {})

    -- Camera Unit
    GameMode:SetFogOfWarDisabled( true )
    local cameraPos = Vector(-300,-4000,50)
    
    if GameRules.PlayersPerTeam == 1 then
        cameraPos.y = -4500
    elseif GameRules.PlayersPerTeam == 2 then
        cameraPos.y = -4500
    elseif GameRules.PlayersPerTeam == 3 then
        cameraPos.x = -200
        cameraPos.y = -4200
    elseif GameRules.PlayersPerTeam == 4 then
        cameraPos.x = -150
        cameraPos.y = -4100
    elseif GameRules.PlayersPerTeam == 6 then
        cameraPos.x = 0
    end

    local centerUnit = CreateUnitByName("dummy_vision", cameraPos, false, nil, nil, 0)

    -- Put players into Winners or Lossers and set the camera
    local winners = {}
    local losers = {}
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:GetSelectedHeroEntity(playerID) then
            PlayerResource:SetCameraTarget(playerID, centerUnit)
            PMP:StopMusic(playerID)
            if not PlayerResource:IsBroadcaster(playerID) then
                local unit = GetPlayerShop(playerID)
                if unit:GetTeamNumber() == winningTeam then
                    table.insert(winners, unit)
                else
                    table.insert(losers, unit)
                end
            end
        end
    end

    -- Win Animations
    for k,unit in pairs(winners) do
        unit:RemoveModifierByName("modifier_building")
        unit:SetAbsOrigin(Vector((k*200)-200,-3800,128))
        unit:SetAngles(0,90,0)
        local race = GetRace(unit)
        local animation = endAnimations[race]
        local duration = victoryAnimDurations[race]/30
        Timers:CreateTimer(function()
            if race == "night_elf" then
                StartAnimation(unit, {duration=duration, activity=animation, rate=1, translate="whats_that"})
            else
                StartAnimation(unit, {duration=duration, activity=animation, rate=1})
            end
            return duration
        end)
    end

    for k,unit in pairs(losers) do
        local position = Vector((k*150)-750,-4000,128)
        unit:RemoveModifierByName("modifier_building")
        ApplyModifier(unit, "modifier_no_health_bar")
        --unit:RemoveModifierByName("modifier_hide")
        unit:SetAbsOrigin(position)
        unit:SetAngles(0,90,0)
    end

    Timers:CreateTimer(2, function()

        -- Do Thunders and shit
        PMP:DoMichaelBayEffects(winners, losers)
    end)
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

victoryAnimDurations = 
{
    ["undead"]  = 132,
    ["peon"]    = 121,
    ["human"]   = 80,
    ["skeleton"]    = 118,
    ["night_elf"]   = 150,
    ["blood_elf"]   = 190,
    ["goblin"]  = 30,
    ["treant"]  = 150,
}

function PMP:DoMichaelBayEffects(winners, losers)
    EmitGlobalSound("PMP.PowerOfTheHorde")

    local outerRight = Vector(-750,-4000,128)
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, Vector(outerRight.x,outerRight.y,2000))
    ParticleManager:SetParticleControl(particle, 1, outerRight) -- point landing
    ParticleManager:SetParticleControl(particle, 2, outerRight) -- point origin

    for k,unit in pairs(losers) do
        Timers:CreateTimer(k*0.2, function()

            local position = Vector((k*150)-750,-4000,128)
            
            -- RIP
            unit:ForceKill(true)
            unit:StartGesture(ACT_DOTA_DIE)

            -- Particles
            local skyPosition = Vector(position.x,position.y,2000) 

            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_CUSTOMORIGIN, nil)
            ParticleManager:SetParticleControl(particle, 0, skyPosition)
            ParticleManager:SetParticleControl(particle, 1, position) -- point landing
            ParticleManager:SetParticleControl(particle, 2, position) -- point origin

            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_earthshock_soil1.vpcf", PATTACH_CUSTOMORIGIN, nil)
            ParticleManager:SetParticleControl(particle, 0, position)
            ParticleManager:SetParticleControl(particle, 1, position)
            ParticleManager:SetParticleControl(particle, 2, position)

            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
            ParticleManager:SetParticleControl(particle, 0, position)
            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast.vpcf", PATTACH_CUSTOMORIGIN, nil)
            ParticleManager:SetParticleControl(particle, 0, position)
            ParticleManager:SetParticleControl(particle, 1, position)

        end)
    end

    Timers:CreateTimer(3.8, function()
        
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particle, 0, Vector(outerRight.x,outerRight.y,2000))
        ParticleManager:SetParticleControl(particle, 1, outerRight)
        ParticleManager:SetParticleControl(particle, 2, outerRight)

        local outerLeft = Vector(750,-4000,128)
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particle, 0, Vector(outerLeft.x,outerLeft.y,2000))
        ParticleManager:SetParticleControl(particle, 1, outerLeft)
        ParticleManager:SetParticleControl(particle, 2, outerLeft)
    end)

    Timers:CreateTimer(4, function()
        local nextWave = RandomFloat(0.1, 0.9)
        for i=0,4 do
            local randomOrigin = Vector(-300,-3900,128) + RandomVector(RandomInt(-300, 600))
            local random = RandomInt(1,3)
            local particleName = lightnings[random]
            
            local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, nil)
            ParticleManager:SetParticleControl(particle, 0, Vector(randomOrigin.x,randomOrigin.y,2000))
            ParticleManager:SetParticleControl(particle, 1, randomOrigin)
            ParticleManager:SetParticleControl(particle, 2, randomOrigin)
        end
        return nextWave
    end)

    Timers:CreateTimer(17, function()
        local origin = Vector(0,-4000,128)

        local particle = ParticleManager:CreateParticle("particles/custom/disruptor_static_storm.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particle, 0, origin) --location
        ParticleManager:SetParticleControl(particle, 1, Vector(2000,2000,1)) --ring
        ParticleManager:SetParticleControl(particle, 2, Vector(100,100,1)) --duration

        Timers:CreateTimer(3,function()
            local randomGround = ground[RandomInt(1,2)]
            local particle = ParticleManager:CreateParticle(randomGround, PATTACH_CUSTOMORIGIN, nil)
            ParticleManager:SetParticleControl(particle, 0, origin) --location
            ParticleManager:SetParticleControl(particle, 1, Vector(1000,1000,1000)) --ring

            return 3
        end)

    end)

    Timers:CreateTimer(28, function()
        for i=0,4 do
            local randomOrigin = Vector(-300,-3900,128) + RandomVector(RandomInt(-500, 800))
            randomOrigin.z = RandomInt(128, 256)
            local random = RandomInt(1,4)
            local particleName = explosions[random]
            
            local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, nil)
            ParticleManager:SetParticleControl(particle, 0, Vector(randomOrigin.x,randomOrigin.y,2000))
            ParticleManager:SetParticleControl(particle, 1, randomOrigin)
            ParticleManager:SetParticleControl(particle, 3, randomOrigin)      
        end
        return 1
    end)

    Timers:CreateTimer(45, function()
        local center = Vector(0,-3800,128)
        local particle = ParticleManager:CreateParticle("particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particle, 0, center)
        ParticleManager:SetParticleControl(particle, 1, center)
 
        local count = 10
        for i=1,count do 
            local rotate_pos = center + Vector(1,0,0) * 500
            local position = RotatePosition(center, QAngle(0, i*36, 0), rotate_pos)
     
            Timers:CreateTimer(i*0.5, function()
                local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_enigma/enigma_blackhole.vpcf", PATTACH_CUSTOMORIGIN, nil)
                ParticleManager:SetParticleControl(particle, 0, position)
                ParticleManager:SetParticleControl(particle, 1, position)
            end)
        end
    end)

end

lightnings = {
    [1] = "particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf",
    [2] = "particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf",
    [3] = "particles/units/heroes/hero_razor/razor_storm_lightning_strike.vpcf",
}

explosions = {
    [1] = "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf",
    [2] = "particles/units/heroes/hero_gyrocopter/gyro_calldown_explosion_second.vpcf",
    [3] = "particles/units/heroes/hero_lina/lina_spell_light_strike_array_explosion.vpcf",
    [4] = "particles/units/heroes/hero_warlock/warlock_rain_of_chaos_explosion.vpcf",
}

ground = {
    [1] = "particles/econ/items/leshrac/leshrac_tormented_staff/leshrac_split_tormented.vpcf",
    [2] = "particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf"
}