if not Tutorial then
    Tutorial = class({})
end

function Tutorial:Init()
    CustomGameEventManager:RegisterListener( "tutorial_start", Dynamic_Wrap(Tutorial, "Start"))
    CustomGameEventManager:RegisterListener( "tutorial_end", Dynamic_Wrap(Tutorial, "End"))

    Tutorial.Active = {}
    Tutorial.Arrows = {}
    Tutorial.HighlightParticles = {}
    Tutorial.HighlightAbilities = {}
    Tutorial.Timers = {}
    Tutorial.Times = {
        ['garage'] = 18,
        ['food'] = 28,
        ['super'] = 37,
        ['goal'] = 59,
        ['towers'] = 66,
        ['pimpery'] = 78,
        ['upgrades'] = 80,
        ['resources'] = 97,
        ['fight'] = 105,
        ['bye'] = 136,
    }
end

function Tutorial:Start(event)
    local playerID = event.PlayerID
    print("[Tutorial] Start for player "..playerID)

    Tutorial.Active[playerID] = true
    Tutorial.HighlightParticles[playerID] = {}
    Tutorial.HighlightAbilities[playerID] = {}
    Tutorial.Timers[playerID] = {}
    ClearTimers(playerID)
    ClearArrowParticles(playerID)
    RemoveHighlightParticles(playerID)
    RemoveHighlightAbilities(playerID)

    -- Center camera on garage
    Tutorial.Timers[playerID][1] = Timers:CreateTimer(Tutorial.Times.garage, function()
        local garage = GetPlayerCityCenter(playerID)
        PMP:RepositionPlayerCamera({pID = playerID, entIndex=garage:GetEntityIndex()})
        Tutorial:HighlightUnitForPlayer(playerID, garage,Tutorial.Times.goal - Tutorial.Times.garage, true)
    end)

    -- highlight food cap and spawn rate buttons
    Tutorial.Timers[playerID][2] = Timers:CreateTimer(Tutorial.Times.food, function()
        local garage = GetPlayerCityCenter(playerID)
        ApplyModifier(garage,"modifier_tutorial", Tutorial.Times.super - Tutorial.Times.food)
        Tutorial:HighlightAbility(playerID, garage:FindAbilityByName("upgrade_food_limit"))
        Tutorial:HighlightAbility(playerID, garage:FindAbilityByName("upgrade_spawn_rate"))
    end)
    
    -- highlight super peon button
    Tutorial.Timers[playerID][3] = Timers:CreateTimer(Tutorial.Times.super, function()
        local garage = GetPlayerCityCenter(playerID)
        local super_peon = GetSuperUnitAbility(garage)
        RemoveHighlightAbilities(playerID)
        Tutorial:HighlightAbility(playerID, super_peon)
    end)
    
    -- ping out all opponent bases
    Tutorial.Timers[playerID][4] = Timers:CreateTimer(Tutorial.Times.goal, function()
        Tutorial:PingEnemyBases(playerID)

        local garage = GetPlayerCityCenter(playerID)
        RemoveHighlightAbilities(playerID)
    end)
    
    -- highlight all your towers
    Tutorial.Timers[playerID][5] = Timers:CreateTimer(Tutorial.Times.towers, function()
        local playerTowers = GetPlayerTowers(playerID)
        for k,tower in pairs(playerTowers) do
            if IsValidAlive(tower) then
                Tutorial:HighlightUnitForPlayer(playerID, tower,Tutorial.Times.pimpery - Tutorial.Times.towers)
            end
        end
    end)
    
    -- highlight pimpery
    Tutorial.Timers[playerID][6] = Timers:CreateTimer(Tutorial.Times.pimpery, function()
        local pimpery = GetPlayerShop(playerID)
        Tutorial:HighlightUnitForPlayer(playerID, pimpery,Tutorial.Times.fight - Tutorial.Times.pimpery)
    end)
    
    -- hightlight upgrade buttons
    Tutorial.Timers[playerID][7] = Timers:CreateTimer(Tutorial.Times.upgrades, function()
        local pimpery = GetPlayerShop(playerID)
        ApplyModifier(pimpery,"modifier_tutorial", Tutorial.Times.resources - Tutorial.Times.upgrades)
        Tutorial:HighlightAbility(playerID, FindAbilityWithName(pimpery, "upgrade_weapon"))
        Tutorial:HighlightAbility(playerID, FindAbilityWithName(pimpery, "upgrade_helm"))
        Tutorial:HighlightAbility(playerID, FindAbilityWithName(pimpery, "upgrade_shield"))
        Tutorial:HighlightAbility(playerID, FindAbilityWithName(pimpery, "upgrade_wings"))
        Tutorial:HighlightAbility(playerID, FindAbilityWithName(pimpery, "upgrade_health"))
    end)
    
    -- highlight resource ui
    Tutorial.Timers[playerID][8] = Timers:CreateTimer(Tutorial.Times.resources, function()
        RemoveHighlightAbilities(playerID)

        local pimpery = GetPlayerCityCenter(playerID)
        Tutorial:HighlightResourceUI(playerID)
    end)
    
    -- particle arrows that point out of your base and towards the others
    Tutorial.Timers[playerID][9] = Timers:CreateTimer(Tutorial.Times.fight, function()
        Tutorial:SignalArrows(playerID)
    end)

    -- on close
    Tutorial.Timers[playerID][10] = Timers:CreateTimer(Tutorial.Times.bye, function()
        Tutorial:End({PlayerID=playerID})
    end)
end

function Tutorial:End(event)
    local playerID = event.PlayerID
    Tutorial.Active[playerID] = false
    ClearArrowParticles(playerID)
    ClearTimers(playerID)
    RemoveHighlightParticles(playerID)
    RemoveHighlightAbilities(playerID)

    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "tutorial_stop_sound", {})
end

function Tutorial:HighlightUnitForPlayer(playerID, unit, time, big)
    local light = "particles/custom/tutorial/highlight_trail_05.vpcf"
    if big then light = "particles/custom/tutorial/highlight_big_trail_05.vpcf" end
    
    unit.highlight = ParticleManager:CreateParticleForPlayer(light, PATTACH_ABSORIGIN, unit, PlayerResource:GetPlayer(playerID))
    table.insert(Tutorial.HighlightParticles[playerID], unit.highlight)

    Timers:CreateTimer(time, function()
        if unit.highlight then
            ParticleManager:DestroyParticle(unit.highlight, true)
        end
    end)
end

function Tutorial:PingEnemyBases(playerID)
    local teamNumber = PlayerResource:GetTeam(playerID)
    print("pings")
    for i=0,12 do
        Timers:CreateTimer(i*0.5, function()
            if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetTeam(i) ~= teamNumber then
                local position = GameRules.StartingPositions[i].position
                if position then
                    MinimapEvent( teamNumber, PlayerResource:GetSelectedHeroEntity(playerID), position.x, position.y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 1 )
                end
            end
        end)
    end
end

function Tutorial:HighlightAbility(playerID, ability)
    if IsValidEntity(ability) then
        table.insert(Tutorial.HighlightAbilities[playerID], ability)
        ToggleOn(ability)
        ability.highlight = true
        ability.highlight = Timers:CreateTimer(0.5, function()
            if IsValidEntity(ability) then
                ability:ToggleAbility()
                ability:EndCooldown()
                return 0.5
            else
                return
            end
        end)
    end
end

function Tutorial:StopHighlightAbility(ability)
    if IsValidEntity(ability) then
        ToggleOff(ability)
        if ability.highlight then
            Timers:RemoveTimer(ability.highlight)
        end
    end
end

function Tutorial:HighlightResourceUI(playerID)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "highlight_resource_panel", {})
end

function Tutorial:SignalArrows(playerID)
    local origin = GameRules.StartingPositions[playerID].position

    local barricadesX = Entities:FindAllByNameWithin("*barricade_positionX*", origin, 1000)
    local barricadesY = Entities:FindAllByNameWithin("*barricade_positionY*", origin, 1000)

    ClearArrowParticles(playerID)
    MakeArrowParticle(playerID, barricadesY[2]:GetAbsOrigin(), 0) --east
    MakeArrowParticle(playerID, barricadesX[1]:GetAbsOrigin(), 90) --north
    MakeArrowParticle(playerID, barricadesY[1]:GetAbsOrigin(), 180) --west
    MakeArrowParticle(playerID, barricadesX[2]:GetAbsOrigin(), 270) --south
end

function MakeArrowParticle( playerID, position, angle )
    local arrow = "particles/custom/tutorial/arrow.vpcf"
    local player = PlayerResource:GetPlayer(playerID)
    local particle = ParticleManager:CreateParticleForPlayer(arrow, PATTACH_CUSTOMORIGIN, nil, player)
    local lookup = position + RotatePosition(Vector(0,0,0), QAngle(0,angle,0), Vector(1,0,0))
    ParticleManager:SetParticleControl(particle, 0, position)
    ParticleManager:SetParticleControl(particle, 1, lookup)
    table.insert(Tutorial.Arrows[playerID], particle)
end

function ClearArrowParticles( playerID )
    if Tutorial.Arrows[playerID] then
        for k,v in pairs(Tutorial.Arrows[playerID]) do
            ParticleManager:DestroyParticle(v, true)
        end
    end
    Tutorial.Arrows[playerID] = {}
end

function ClearTimers( playerID )
    if Tutorial.Timers[playerID] then
        for i=1,10 do
            if Tutorial.Timers[playerID][i] then
                Timers:RemoveTimer(Tutorial.Timers[playerID][i])
            end
        end
    end
end

function RemoveHighlightParticles(playerID)
    if not Tutorial.HighlightParticles[playerID] then return end
    for k,particle in pairs(Tutorial.HighlightParticles[playerID]) do
        if particle then
            ParticleManager:DestroyParticle(particle, true)
        end
    end

    Tutorial.HighlightParticles[playerID] = {}
end

function RemoveHighlightAbilities(playerID)
    if not Tutorial.HighlightAbilities[playerID] then return end
    for k,ability in pairs(Tutorial.HighlightAbilities[playerID]) do
        Tutorial:StopHighlightAbility(ability)
    end
    Tutorial.HighlightAbilities[playerID] = {}
end


if not Tutorial.Arrows then Tutorial:Init() end