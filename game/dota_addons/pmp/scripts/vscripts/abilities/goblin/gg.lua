-- OnEntityKilled
if killedUnit:IsCreature() then
    local gold_bounty = GetGoldCost(killedUnit)
    local lumber_bounty = GetLumberCost(killedUnit)

    if killer:HasAbility("goblin_greed") then
        local bounty_ability = killer:FindAbilityByName("goblin_greed")
        local extra_bounty = bounty_ability:GetSpecialValueFor("extra_bounty")
        gold_bounty = gold_bounty + extra_bounty
        lumber_bounty = lumber_bounty + extra_bounty
    end

    GiveBounty(killer, killedUnit)
end