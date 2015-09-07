-- OnEntityKilled
--  give team bounty (Read GoldBounty and LumberBounty KVs)
--  remove 1 layer of invulnerability to the owner hero of that tower (hero.invulnCount = -1)
--  if invulnerability reaches 0, remove modifier_invulnerable from hero.city_center

-- Have one fake passive ability on the towers for tooltip

if IsCustomTower(npc) then
    GiveBountyToTeam(killer:GetTeamNumber(), npc)
    ReduceInvulnerabilityCount(npc:GetOwner())
end

-- Units should have no "BountyGoldMin" and "BountyGoldMax", using "GoldCost" and "LumberCost" instead 
function GiveBountyToTeam( teamNumber, unit )
    local gold_bounty = GetGoldCost(unit)
    local lumber_bounty = GetLumberCost(unit)
    for i=0,DOTA_MAX_DOTA_MAX_TEAM_PLAYERS do
        if IsValidPlayerID(i) then
            local player = PlayerResource:GetPlayer(i)
            local hero = player:GetAssignedHero()
            ModifyGold(hero, gold_bounty)
            PopupGoldGain(hero, gold_bounty)

            ModifyLumber(hero, lumber_bounty)
            PopupLumber(hero, lumber_bounty)
        end 
    end
end

--Modify Gold/Lumber should handle 0 value if they aren't doing it already
--Get Gold/Lumber Cost should handle nil value (default to 0)


function ReduceInvulnerabilityCount( hero )
    if not hero.invulnCount then
        hero.invulnCount = 4
    end

    hero.invulnCount = hero.invulnCount - 1

    if hero.invulnCount == 0 then
        hero.city_center:RemoveModifierByName("modifier_invulnerable")
    end
end