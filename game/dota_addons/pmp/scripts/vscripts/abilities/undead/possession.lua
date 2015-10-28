function PossessionCheck ( event )
    local PlayerID = event.caster:GetPlayerOwnerID()
    local channel_duration = event.ability:GetSpecialValueFor("channel_duration")
    local ability = event.ability
    local target = event.target
    local caster = event.caster

    if target:GetLevel() > 5 then
        -- store mana   
        local mana = event.caster:GetMana()
        
        -- interupt & send error
        caster:Interrupt()         
        SendErrorMessage(PlayerID, "#error_cant_target_level6")
        
        -- set mana after a frame delay
        Timers:CreateTimer(function() caster:SetMana(mana) return end)
    else
        caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)

        ability:ApplyDataDrivenModifier(caster, target, "modifier_possession_target", {duration=channel_duration+1})
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_possession_caster", {duration=channel_duration})
        caster:EmitSound("Hero_DeathProphet.Exorcism.Cast")
    end
end

function Possession( event )
    local target = event.target
    local caster = event.caster
    local ability = event.ability

    caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
    Timers:CreateTimer(function()
    
        -- incase the unit has finished channelling but dies mid-possession(highly unlikely but possible)
        if not IsValidAlive(caster) then 
            return
        end
        
        local casterposition = caster:GetAbsOrigin()
        local targetposition = target:GetAbsOrigin()
        
        caster:EmitSound("Hero_DeathProphet.Exorcism.Damage")

        if (casterposition-targetposition):Length2D() < 10 then

            -- particle management
            ParticleManager:CreateParticle("particles/units/heroes/hero_death_prophet/death_prophet_excorcism_attack_impact_death.vpcf", 1, target)

            -- Remove the unit from the enemy player unit list
            local oldOwnerID = target:GetPlayerOwnerID()
            if oldOwnerID then
                local targetPlayerUnits = GetPlayerUnits(oldOwnerID)
                if targetPlayerUnits then
                    local unit_index = getIndexTable(targetPlayerUnits, target)
                    if unit_index then
                        table.remove(targetPlayerUnits, unit_index)
                    end
                end
            end

            -- convert target unit information to match caster
            local newOwner = caster:GetOwner()
            local newOwnerID = caster:GetPlayerOwnerID()
            local newTeam = PlayerResource:GetTeam(newOwnerID)
            target:SetOwner(newOwner)
            target:SetControllableByPlayer(newOwnerID, true)
            target:SetTeam(newTeam)
            target:EmitSound("Hero_DeathProphet.Death")
            target.summoned = true --skips the -1 food decrease

            -- kill and set selection
            AddUnitToSelection(target)
            RemoveUnitFromSelection(caster)
            caster:ForceKill(true)
            caster:AddNoDraw()

            --kill timer
            return nil
        else
            
            -- update position, Caster moves towards Target
            caster:SetAbsOrigin(caster:GetAbsOrigin() + (target:GetAbsOrigin() - caster:GetAbsOrigin()))    
        end
        return 0.2
    end)
end