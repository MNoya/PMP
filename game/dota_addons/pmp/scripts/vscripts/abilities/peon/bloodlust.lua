function Bloodlust(event)   
    local caster = event.caster
    local target = event.target
    local ability = event.ability

    if target.bloodlust_timer then
        Timers:RemoveTimer(target.bloodlust_timer)
    end

    local scaling_factor = ability:GetSpecialValueFor('scaling_factor')
    local model_scale = GetOriginalModelScale(target) or 1
    local final_model_scale = model_scale * (1+scaling_factor)
    local model_size_interval = scaling_factor/25
    local interval = 0.03
    target.bloodlust_timer = Timers:CreateTimer(interval, function() 
            local current_scale = target:GetModelScale()
            if current_scale <= final_model_scale then
                local modelScale = current_scale + model_size_interval
                target:SetModelScale( modelScale )
                return 0.03
            else
                return
            end
        end)

    ability:ApplyDataDrivenModifier(caster, target, 'modifier_bloodlust', nil) 

    caster:EmitSound('Hero_OgreMagi.Bloodlust.Cast')
    target:EmitSound('Hero_OgreMagi.Bloodlust.Target')
end

function BloodlustDelete(event) 
    local target = event.target
    local ability = event.ability
    local scaling_factor = ability:GetSpecialValueFor('scaling_factor')
    local final_model_scale = GetOriginalModelScale(target) or 1
    local model_size_interval = scaling_factor/50
    
    if target.bloodlust_timer then
        Timers:RemoveTimer(target.bloodlust_timer)
    end
    local interval = 0.03
    target.bloodlust_timer = Timers:CreateTimer(interval, function() 
            local current_scale = target:GetModelScale()
            if current_scale >= final_model_scale then
                local modelScale = current_scale - model_size_interval
                target:SetModelScale( modelScale )
                return 0.03
            else
                return
            end
        end)

end

-- Handles the autocast logic
function BloodlustAutocast( event )
    local caster = event.caster
    local target = event.target -- victim of the attack
    local ability = event.ability

    -- Name of the modifier to avoid casting the spell on targets that were already buffed
    local modifier = "modifier_bloodlust"

    -- Get if the ability is on autocast mode and cast the ability on the attacked target if it doesn't have the modifier
    if ability:GetAutoCastState() then
        if not target:HasModifier(modifier) then
            caster:CastAbilityOnTarget(target, ability, caster:GetPlayerOwnerID())
        end 
    end 
end

-- Automatically toggled on
function ToggleOnAutocast( event )
    local caster = event.caster
    local ability = event.ability

    ability:ToggleAutoCast()
end