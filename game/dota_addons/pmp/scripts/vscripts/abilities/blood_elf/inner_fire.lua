-- Handles the autocast logic
function InnerFireAutocast_Attack( event )
    local caster = event.caster
    local attacker = event.attacker
    local ability = event.ability
    if not ability then return end
    local modifier = "modifier_inner_fire"

    if not attacker:IsMagicImmune() and ability:GetAutoCastState() and ability:IsFullyCastable() and not caster:IsSilenced() then
        if not attacker:HasModifier(modifier) then
            caster:CastAbilityOnTarget(attacker, ability, caster:GetPlayerOwnerID())
        end 
    end 
end

function InnerFireAutocast_Attacked( event )
    local caster = event.caster
    local target = event.target
    local ability = event.ability
    if not ability then return end
    local modifier = "modifier_bloodlust"

    if not target:IsMagicImmune() and ability:GetAutoCastState() and ability:IsFullyCastable() and not caster:IsSilenced() then
        if not target:HasModifier(modifier) then
            caster:CastAbilityOnTarget(target, ability, caster:GetPlayerOwnerID())
        end 
    end 
end