-- Denies cast on creeps higher than level 5, with a message
function PolymorphLevelCheck( event )
    local target = event.target
    local caster = event.caster
    local pID = caster:GetPlayerOwnerID()
    
    if target:GetLevel() > 5 then
        event.caster:Interrupt()
        SendErrorMessage(pID, "#error_cant_target_level6")
    end
end