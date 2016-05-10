function BossDamaged( event )
    local boss = event.caster
    local attacker = event.attacker
    local ability = event.ability
    local damage = event.Damage

    -- Check if the damage would be lethal
    local health = boss:GetHealth()
    if health <= 0 and not boss.playerControlled then

        local playerID = attacker:GetPlayerOwnerID()
        print("[PMP] Giving boss control over "..playerID)
        SendBossFocusMessage(playerID)

        boss:Heal(damage, boss)
        if boss:HasAbility("boss_roam") then
            boss:RemoveAbility("boss_roam")
        end

        boss:SetTeam(attacker:GetTeamNumber())
        boss:SetControllableByPlayer(playerID, true)
        boss.playerControlled = true
        boss:RespawnUnit()
        boss:SetHealth(boss:GetMaxHealth())

        Sounds:EmitSoundOnClient(playerID, "Announcer.Boss.Slain.Self")
        local slainSound = RollPercentage(10) and "Announcer.Boss.Slain.Rare" or "Announcer.Boss.Slain"
        -- Play slain sound for the others
        for i=0,12 do
            if PlayerResource:IsValidPlayer(i) and i~=playerID then
                Sounds:EmitSoundOnClient(i, slainSound)
            end
        end
    end
end

function Devour( event )
    local boss = event.caster
    local target = event.target

    for i=0,15 do
        local ability = target:GetAbilityByIndex(i)
        if ability then
            local abilityName = ability:GetAbilityName()
            if not boss:HasAbility(abilityName) and ability:GetBehavior() == DOTA_ABILITY_BEHAVIOR_PASSIVE and not restricted_devour_skills[abilityName] then
                TeachAbility(boss, abilityName)
            end
        end
    end

    AdjustAbilityLayout(boss)

    HideUnit(target)
    target:ForceKill(true)
end

restricted_devour_skills = {
["night_elf_racial"]={}, 
["night_elf_trueshot_aura"]={},
["undead_racial"]={},
["goblin_racial"]={},
["blood_elf_racial"]={},
["treant_racial"]={},
["skeleton_racial"]={},
["barrage_attack"]={},
["skeleton_reincarnation_aura"]={},
["demon_evasion"]={},
["demon_rush"]={},
}

function ApplyStacks( event )
    local boss = event.caster
    local ability = event.ability
    local modifierName = "modifier_boss_stacks"
    
    local time = GameRules:GetDOTATime(false, true)
    print("Boss spawned at ",time)
    local stacks = math.floor(time / 180)

    if stacks <= 0 then return end
    
    ability:ApplyDataDrivenModifier(boss, boss, modifierName, {})
    boss:SetModifierStackCount(modifierName, boss, stacks)

    -- Scale
    local increase = 0.2*math.log(tonumber(stacks+1),2)
    local scale = 0.8+increase
    boss:SetModelScale(scale)

    -- Health
    local health = 2000+1000*stacks
    local relativeHealth = boss:GetHealthPercent() * 0.01
    boss:SetBaseMaxHealth(health)
    boss:SetMaxHealth(health)
    local newRelativeHealth = math.ceil(boss:GetMaxHealth() * relativeHealth)
    
    if newRelativeHealth > 0 then
        boss:SetHealth(newRelativeHealth)
    end
end

function UpdateStacks( event )
    local boss = event.caster
    local ability = event.ability
    local modifierName = "modifier_boss_stacks"
    
    local time = GameRules:GetDOTATime(false, true)
    local stacks = math.floor(time / 180)

    if stacks <= 0 then return end

    if boss:HasModifier(modifierName) then
        boss:SetModifierStackCount(modifierName, boss, stacks)
    else
        ability:ApplyDataDrivenModifier(boss, boss, modifierName, {})
        boss:SetModifierStackCount(modifierName, boss, stacks)
    end

    -- Scale
    local increase = 0.2*math.log(tonumber(stacks+1),2)
    local scale = 0.8+increase
    boss:SetModelScale(scale)

    -- Health
    local health = 2000+1000*stacks
    local relativeHealth = boss:GetHealthPercent() * 0.01
    boss:SetBaseMaxHealth(health)
    boss:SetMaxHealth(health)
    local newRelativeHealth = math.ceil(boss:GetMaxHealth() * relativeHealth)
    
    if newRelativeHealth > 0 then
        boss:SetHealth(newRelativeHealth)
    end
end

function StartRespawn( event )
    local boss = event.caster
    local time_to_respawn = 300

    print("[PMP] Boss Killed, respawning in "..time_to_respawn.." seconds")
    GameRules.TimesBossKilled = GameRules.TimesBossKilled and (GameRules.TimesBossKilled + 1) or 1

    Timers:CreateTimer(time_to_respawn, function()
        if not IsValidAlive(GameRules.boss) then
            print("[PMP] Respawn Boss")
            PMP:SpawnBoss()
            EmitGlobalSound("Announcer.Boss.Respawned")
        end
    end)
end