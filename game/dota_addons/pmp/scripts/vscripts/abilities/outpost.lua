function ActivateOutpost( event )
    local outpost = event.caster
    local ability = event.ability
    local playerID = outpost:GetPlayerOwnerID()
    local outposts = GetPlayerOutposts(playerID)

    -- Toggle off all other outposts
    for k,v in pairs(outposts) do
        if v ~= outpost then
            local outpost_ability = v:FindAbilityByName("active_outpost")
            if outpost_ability then
                ToggleOff(outpost_ability)
            end
        end
    end

    -- Set units to spawn from here now
    print("SetActive")
    SetActiveOutpost(playerID, outpost)
end

function DisableOutpost( event )
    local outpost = event.caster
    local ability = event.ability
    local playerID = outpost:GetPlayerOwnerID()

    -- Stop units from spawning from here
    print("DisableOutpost")
    DeactivateOutpost(playerID)
end

function OutpostDamaged( event )
    local outpost = event.caster
    local attacker = event.attacker
    local ability = event.ability
    local damage = event.Damage

    -- Check if the damage would be lethal
    local health = outpost:GetHealth()
    if health <= 0 then

        outpost:Heal(damage, outpost)
        outpost:SetHealth(1)
        
        ChangeOutpostControl(outpost, attacker:GetPlayerOwnerID())
    end
end