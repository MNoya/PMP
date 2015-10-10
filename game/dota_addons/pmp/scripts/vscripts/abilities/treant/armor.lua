-- Handles the autocast logic
function LivingArmorAutocast_Attack( event )
    local caster = event.caster
    local attacker = event.attacker
    local ability = event.ability
    if not ability then return end

    if IsLeaderUnit(attacker) then return end

    -- Name of the modifier to avoid casting the spell on targets that were already buffed
    local modifier = "modifier_treant_armor"

    -- Get if the ability is on autocast mode and cast the ability on the attacked target if it doesn't have the modifier
    if not attacker:IsMagicImmune() and ability:GetAutoCastState() and ability:IsFullyCastable() then
        if not attacker:HasModifier(modifier) then
            caster:CastAbilityOnTarget(attacker, ability, caster:GetPlayerOwnerID())
        end 
    end 
end

function LivingArmorAutocast_Attacked( event )
    local caster = event.caster
    local target = event.target
    local ability = event.ability
    if not ability then return end

    if IsLeaderUnit(target) then return end

    -- Name of the modifier to avoid casting the spell on targets that were already buffed
    local modifier = "modifier_treant_armor"

    -- Get if the ability is on autocast mode and cast the ability on the attacked target if it doesn't have the modifier
    if not target:IsMagicImmune() and ability:GetAutoCastState() and ability:IsFullyCastable() then
        if not target:HasModifier(modifier) then
            caster:CastAbilityOnTarget(target, ability, caster:GetPlayerOwnerID())
        end 
    end 
end