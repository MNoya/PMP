-------------------------------

AI_THINK_INTERVAL = 0.5
AI_STATE_IDLE = 0
AI_STATE_AGGRESSIVE = 1
AI_STATE_RETURNING = 2
AI_STATE_ROAMING = 3
AI_STATE_AGGRO_ROAM = 4
ROAM_INTERVAL = 180

BossAI = {}
BossAI.__index = BossAI

function BossAI:Start( unit )
    local ai = {}
    setmetatable( ai, BossAI )

    --Set the core fields for this AI
    ai.unit = unit
    ai.state = AI_STATE_IDLE
    ai.stateThinks = {
        [AI_STATE_IDLE] = 'IdleThink',
        [AI_STATE_AGGRESSIVE] = 'AggressiveThink',
        [AI_STATE_RETURNING] = 'ReturningThink',
        [AI_STATE_ROAMING] = 'RoamingThink',
        --[AI_STATE_AGGRO_ROAM] = 'AggroRoamThink',
    }

    unit.spawnPos = unit:GetAbsOrigin()
    unit.aggroRange = unit:GetAcquisitionRange()
    unit.leashRange = unit:GetAcquisitionRange()+100
    unit.bRoam = GameRules.BossRoam
    unit.roamTime = GameRules:GetDOTATime(false, true)
    unit.roamPoints = Entities:FindAllByName("boss_roam_point")
    unit.devourAbility = unit:FindAbilityByName("boss_devour")
    unit.shockwaveAbility = unit:FindAbilityByName("boss_shockwave")

    if unit.bRoam then

        if unit.roamTime < 10 then
            GameRules:SendCustomMessage("Boss Roam Enabled!", 0, 0)
        end

        TeachAbility(unit, "boss_roam")

        Timers:CreateTimer(1, function()
            if unit:IsAlive() then
                for i=0,DOTA_TEAM_COUNT do
                    AddFOWViewer ( i, unit:GetAbsOrigin(), 1000, 1.1, false)
                end
                return 1
            end
        end)       
    end

    --Start thinking
    Timers:CreateTimer( ai.GlobalThink, ai )

    --Return the constructed instance
    return ai
end

function BossAI:GlobalThink()
    local unit = self.unit

    --If the unit is dead, stop thinking
    if not unit:IsAlive() then
        return nil
    end

    -- Player controlled
    if unit.playerControlled then
        return nil
    end

    Dynamic_Wrap(BossAI, self.stateThinks[ self.state ])( self )

    --Reschedule this thinker to be called again after a short duration
    return AI_THINK_INTERVAL
end

-- AI_STATE_IDLE
function BossAI:IdleThink()
    local unit = self.unit

    --Find any enemy units around the AI unit inside the aggroRange
    local units = FindEnemiesInAggroRange(unit)

    if ShouldRoam(unit) then
        unit.roamPosition = GetRoamPoint(unit)
        self.state = AI_STATE_ROAMING
        ApplyModifier(unit, "modifier_roaming")
        unit:StartGesture(ACT_DOTA_MAGNUS_SKEWER_END)
        GameRules:SendCustomMessage("The Boss starts roaming!", 0, 0)
        EmitGlobalSound("Announcer.Boss.Roaming")
        print("IDLE -> ROAM")
        return true
    end

    --If one or more units were found, start attacking the first one
    if #units > 0 then
        unit:MoveToTargetToAttack( units[1] )
        unit.aggroTarget = units[1]
        print("Enemy units found. IDLE -> AGGRESSIVE")
        self.state = AI_STATE_AGGRESSIVE
        return true
    end

    --State behavior
end

-- AI_STATE_ROAMING
function BossAI:RoamingThink()
    local unit = self.unit
    local roamPosition = unit.roamPosition
    local distance_to_position = (roamPosition - unit:GetAbsOrigin() ):Length2D()

    if distance_to_position < 100 then

        --[[ Find base nearby
        local units = FindUnitsInRadius( unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, 2500, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false )

        local highestKiller
        if #units > 0 then

            -- Choose a player to focus
            local maxKills = 0
            for k,unit in pairs(units) do
                local playerOwnerID = unit:GetPlayerOwnerID()
                if PlayerResource:GetKills(playerOwnerID) >= maxKills then
                    highestKiller = playerOwnerID
                end
            end
        end

        -- If a player is found, move to attack
        if highestKiller then

            unit.playerFocus = highestKiller
            unit.playerBaseFocus = GameRules.StartingPositions[unit.playerFocus].position + RandomVector(200)

            -- "The boss now charges against..."
            SendBossFocusMessage(highestKiller)

            unit:MoveToPosition(unit.playerBaseFocus)

            print("Focusing player "..highestKiller..". ROAM -> AGGRO_ROAM")
            self.state = AI_STATE_AGGRO_ROAM
        else
        end]]

        print("Reached Position. ROAM -> IDLE")
        unit.spawnPos = unit:GetAbsOrigin() --Update new leash position
        self.state = AI_STATE_IDLE

        unit:RemoveModifierByName("modifier_roaming")
        unit:RemoveGesture(ACT_DOTA_MAGNUS_SKEWER_END)
    else
        unit:MoveToPosition(roamPosition)
    end
end

-- AI_STATE_AGGRESSIVE
function BossAI:AggressiveThink()
    local unit = self.unit
        
    --Check if the unit has walked outside its leash range
    if ( unit.spawnPos - unit:GetAbsOrigin() ):Length() > unit.leashRange then
        unit:MoveToPosition( unit.spawnPos )
        print("Reached max leash range. AGGRESSIVE -> RETURNING")
        self.state = AI_STATE_RETURNING
        return true
    end

    if ShouldRoam(unit) then
        unit.roamPosition = GetRoamPoint(unit)
        ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = unit.roamPosition, Queue = false}) 
        ApplyModifier(unit, "modifier_roaming")
        unit:StartGesture(ACT_DOTA_MAGNUS_SKEWER_END)
        self.state = AI_STATE_ROAMING
        print("Stopping Aggro. AGGRO -> ROAM")
        return true
    end

    --Check if the unit's target is still alive
    if not unit.aggroTarget:IsAlive() then

        local units = FindEnemiesInAggroRange(unit)

        if #units > 0 then
            unit.aggroTarget = units[1]
        else
            -- If the roam mode is enabled, stay idle, otherwise return
            if unit.bRoam then
                unit.aggroTarget = nil
                print("All enemy units are dead (BossRoam is ON). AGGRESSIVE -> IDLE")
                self.state = AI_STATE_IDLE
            else
                print("All enemy units are dead. AGGRESSIVE -> RETURNING")
                unit:MoveToPosition( unit.spawnPos )
                self.state = AI_STATE_RETURNING
            end
        end
        return true
    end

    -- Cast Spells
    if unit.devourAbility:IsFullyCastable() then
        unit:CastAbilityOnTarget(unit.aggroTarget, unit.devourAbility, -1)
        return true
    end

    local frontUnits = GetUnitsInFront(unit)
    if #frontUnits > 5 and unit.shockwaveAbility:IsFullyCastable() and not unit.shockwaveAbility:IsInAbilityPhase() then
        local point = unit:GetAbsOrigin() + unit:GetForwardVector() * 500
        unit:CastAbilityOnPosition(point, unit.shockwaveAbility, -1)
        return true
    end
end

-- AI_STATE_RETURNING
function BossAI:ReturningThink()
    local unit = self.unit

    --Check if the AI unit has reached its spawn location yet
    if ( unit.spawnPos - unit:GetAbsOrigin() ):Length() < 10 then
        print("Reached spawn position. RETURNING -> IDLE")
        self.state = AI_STATE_IDLE
        return true
    else
        unit:MoveToPosition( unit.spawnPos )
    end
end

-- AI_STATE_AGGRO_ROAM
function BossAI:AggroRoamThink()
    local unit = self.unit

    local playerFocus = unit.playerFocus
    local baseFocus = unit.playerBaseFocus    
    local distance_to_base = ( baseFocus - unit:GetAbsOrigin() ):Length2D()

    if ShouldRoam(unit) then
        unit.roamPosition = GetRoamPoint(unit)
        ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = unit.roamPosition, Queue = false}) 
        ApplyModifier(unit, "modifier_roaming")
        unit:StartGesture(ACT_DOTA_MAGNUS_SKEWER_END)
        self.state = AI_STATE_ROAMING
        print("Stopping Aggro. AGGRO -> ROAM")
        return true
    end

    -- Keep moving until close to the base
    if distance_to_base < 1000 then

        -- Find enemies to attack
        local enemy = FindEnemyFocusing(unit, baseFocus)

        if enemy then
            unit:MoveToTargetToAttack( enemy )
            unit.aggroTarget = enemy
            self.state = AI_STATE_AGGRESSIVE
        else
            self.state = AI_STATE_IDLE
        end
    end
end

---------------------------------------------------

function ShouldRoam(unit)
    local time = GameRules:GetDOTATime(false, true)

    if unit.bRoam then

        local time = GameRules:GetDOTATime(false, true)
        if (time - unit.roamTime) > ROAM_INTERVAL then 
            -- Update the new roam time
            unit.roamTime = time
            return true
        else
            return false
        end
    else
        return false
    end
end
    
function GetRoamPoint(unit)
    -- Get a random roam point
    local nPoints = #unit.roamPoints
    local randomPoint = RandomInt(1,nPoints)
    local ent = unit.roamPoints[randomPoint]
    local position = ent:GetAbsOrigin()
    local distance_to_position = (unit:GetAbsOrigin() - position):Length2D()

    -- Ensure its a different position that the one the unit is standing on
    while (distance_to_position < 100) do
        randomPoint = RandomInt(1,nPoints)
        ent = unit.roamPoints[randomPoint]
        position = ent:GetAbsOrigin()
        distance_to_position = (unit:GetAbsOrigin() - position):Length2D()
    end

    return position
end

function FindEnemiesInAggroRange( unit )
    local units = FindUnitsInRadius( unit:GetTeamNumber(), unit:GetAbsOrigin(), nil,
        unit.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_ANY_ORDER, false )

    return units
end

function FindEnemyFocusing( unit, teamNumber )
    local units = FindUnitsInRadius( unit:GetTeamNumber(), unit:GetAbsOrigin(), nil,
        2000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_CLOSEST, false )

    local focusUnit
    if #units > 0 then
        for k,v in pairs(units) do
            if v:GetTeamNumber() == teamNumber then
                focusUnit = v
                break
            end
        end

        return focusUnit or units[1]
    end
end

function GetUnitsInFront( unit )
    local radius = 250
    local front = unit:GetAbsOrigin() + unit:GetForwardVector() * radius

    local units1 = FindUnitsInRadius( unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, radius, 
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_ANY_ORDER, false )

    if #units1 > 0 then
        return units1
    else
       local units2 = FindUnitsInRadius( unit:GetTeamNumber(), front, nil, radius, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
            FIND_ANY_ORDER, false )
       return units2
    end

end