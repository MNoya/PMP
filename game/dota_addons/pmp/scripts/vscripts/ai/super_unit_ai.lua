if not SuperUnitAI then
    SuperUnitAI = {}
    SuperUnitAI.__index = SuperUnitAI
end

function SuperUnitAI:Start(playerID, unit)
    local ai = {}
    setmetatable( ai, SuperUnitAI )

    ai.unit = unit --The unit this AI is controlling
    ai.ThinkInterval = 0.5
    ai.heightRestriction = 180
    ai.playerID = playerID
    unit.range = unit:GetAttackRange()
    unit:SetIdleAcquire(true)
    unit.move_points = GenerateNumPointsAround(4, unit:GetAbsOrigin(), 400)

    --Start thinking
    Timers:CreateTimer(function()
        return ai:GlobalThink()
    end)

    return ai
end

function SuperUnitAI:GlobalThink()
    local unit = self.unit

    if not IsValidAlive(unit) then
        return nil
    end

    Dynamic_Wrap(SuperUnitAI, "Think")( self )

    return self.ThinkInterval
end

function SuperUnitAI:Think()
    local unit = self.unit
    local randomPos = unit:GetAbsOrigin() + RandomVector(200)

    -- Don't let it go near a point where it would exit the base
    if unit:GetAbsOrigin().z < self.heightRestriction + 30 then
        while GetGroundPosition(randomPos, unit).z < 256 do
            randomPos = unit:GetAbsOrigin() + RandomVector(200)
        end

        unit:MoveToPosition(randomPos)
        return
    end

    -- Move to one of the predetermined points near base
    if unit:IsIdle() then
        unit:MoveToPositionAggressive(unit.move_points[RandomInt(1, #unit.move_points)])
    end
end