TELEPORT_DELAY = 0.15
function TeleportSouth( trigger )
    local unit = trigger.activator

    if IsPimpUnit(unit) and not unit:HasModifier("modifier_teleport_sickness") then

        local position = unit:GetAbsOrigin()
        PlayTeleportParticle(unit)
        position.y = position.y-8200

        TeleportUnit(unit, position)
    end
end

function TeleportNorth( trigger )
    local unit = trigger.activator

    if IsPimpUnit(unit) and not unit:HasModifier("modifier_teleport_sickness") then

        local position = unit:GetAbsOrigin()
        PlayTeleportParticle(unit)
        position.y = position.y+8200

        TeleportUnit(unit, position)
    end
end

function TeleportEast( trigger )
    local unit = trigger.activator

    if IsPimpUnit(unit) and not unit:HasModifier("modifier_teleport_sickness") then

        local position = unit:GetAbsOrigin()
        PlayTeleportParticle(unit)
        if GetMapName() == "free_for_all" then
            position.x = position.x+8200
        else
            position.x = position.x+10500
        end

        TeleportUnit(unit, position)
    end
end

function TeleportWest( trigger )
    local unit = trigger.activator

    if IsPimpUnit(unit) and not unit:HasModifier("modifier_teleport_sickness") then

        local position = unit:GetAbsOrigin()
        PlayTeleportParticle(unit)
        if GetMapName() == "free_for_all" then
            position.x = position.x-8200
        else
            position.x = position.x-10500
        end

        TeleportUnit(unit, position)
    end
end

function PlayTeleportParticle( unit )
    local particle = ParticleManager:CreateParticle("particles/custom/teleport_unit_a.vpcf", PATTACH_CUSTOMORIGIN, unit)
    ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin())
end

function TeleportUnit( unit, position )
    Timers:CreateTimer(TELEPORT_DELAY, function()
        FindClearSpaceForUnit(unit, position, true)
        ApplyModifier(unit, "modifier_teleport_sickness")
        Timers:CreateTimer(0.5, function()
            unit:Stop()
        end)
    end)
end