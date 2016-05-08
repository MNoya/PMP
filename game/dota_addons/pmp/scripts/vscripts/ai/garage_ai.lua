if not GarageAI then
    GarageAI = {}
    GarageAI.__index = GarageAI
end

function GarageAI:Start(playerID, unit)
    local ai = {}
    setmetatable( ai, GarageAI )

    ai.unit = unit --The unit this AI is controlling
    ai.playerID = playerID
    ai.ThinkInterval = 0.5
    unit.range = unit:GetAttackRange()
    unit:SetIdleAcquire(true)
    unit.superPeonAbility = GetSuperUnitAbility(unit)

    --Start thinking
    Timers:CreateTimer(function()
        return ai:GlobalThink()
    end)

    return ai
end

function GarageAI:GlobalThink()
    local unit = self.unit

    if not IsValidAlive(unit) then
        return nil
    end

    Dynamic_Wrap(GarageAI, "Think")( self )

    return self.ThinkInterval
end

function GarageAI:Think()
    local unit = self.unit
    local target = unit:GetAttackTarget()
    local enemies = {}

    if not target or not target:IsAlive() or unit:GetRangeToUnit(target) > unit.range then
        enemies = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, unit.range+unit:GetHullRadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)
        for _,enemy in pairs(enemies) do
            if not target then
                target = enemy
            elseif IsLeaderUnit(enemy) or enemy:GetHealthPercent() <= 50 then
                target = enemy
                break
            end
        end
    end

    if target then
        unit:MoveToTargetToAttack(target)
    end

    -- Should we use a super peon?
    local charges = unit:GetModifierStackCount("modifier_super_unit_charges", unit)
    local numEnemies = #enemies
    if numEnemies > 0 and charges > 0 and unit.superPeonAbility and unit.superPeonAbility:IsFullyCastable() then
        local bCast = false

        -- Cast early for advantage
        if charges == 3 then
            bCast = numEnemies >= 10

        -- Later if we can secure many kills with it
        elseif charges == 2 then
            bCast = numEnemies >= 20 or (numEnemies >= 10 and GetInvunerabilityCount(self.playerID) <= 2 and GetFoodUsed(self.playerID) <= GetSpawnRate(self.playerID))

        -- Last one for emergency
        elseif charges <= 2 then
            bCast = (numEnemies >= 10 and unit:GetHealthPercent() < 80) or (numEnemies >= GetSpawnRate(self.playerID) and unit:GetHealthPercent() < 20)
        end

        if bCast then
            AI:Log(self.playerID, "Cast Super Peon ("..(charges-1).." left) with "..numEnemies.." nearby")
            unit.superPeonAbility:CastAbility()
            unit.superPeonAbility:StartCooldown(20)
        end
    end
end