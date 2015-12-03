upgrade_health = class ({})
health = class ({})

function upgrade_health:OnSpellStart()
    local ability = self

    local caster = ability:GetCaster()
    local level = ability:GetLevel()
    local pID = caster:GetPlayerOwnerID()

    PMP:SetUpgrade( pID, "health", level )

    local maxLevel = 100
    if level == maxLevel then
        ability:SetHidden(true)
        
        Sounds:EmitSoundOnClient(pID, "Announcer.Upgrade.Health.Max")
    else
        Sounds:EmitSoundOnClient(pID, "Announcer.Upgrade.Health")

        ability:SetLevel(level + 1)
    end

    return 
end

function upgrade_health:GetGoldCost()
    local ability = self

    local baseGoldCost = 10
    local extraGoldPerLevel = 5
    local level = ability:GetLevel()
    
    local newGoldCost = baseGoldCost + (level-1) * extraGoldPerLevel
    
    -- Restrict gold to 999 (max number displayed)
    if newGoldCost >= 1000 then
        newGoldCost = 999
    end

    return (newGoldCost)
end

function upgrade_health:OnToggle()
    if self:GetToggleState() then
        self:GetCaster():GetOwner():ModifyGold(self:GetGoldCost(self:GetLevel()), false, 0)
    end
end

function upgrade_health:GetBehavior()
    local behav = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    local caster = self:GetCaster()

    if caster:HasModifier("modifier_tutorial") then      
        return behav + DOTA_ABILITY_BEHAVIOR_TOGGLE
    else
        return behav
    end
end

-- Passive ability on the units
function health:OnUpgrade()
    local ability = self

    local unit = ability:GetCaster()
    local level = ability:GetLevel()

    local unit_name = unit:GetUnitName()
    local unitUnmodifiedBaseHealth = GameRules.UnitKV[unit_name]["StatusHealth"]
    local bonus_health_total = unitUnmodifiedBaseHealth * 0.1 * level
    local newHP = unitUnmodifiedBaseHealth + bonus_health_total
    local currentHealthPercentage = unit:GetHealth()/unit:GetMaxHealth()
    unit:SetMaxHealth(newHP)
    unit:SetBaseMaxHealth(newHP)
    unit:SetHealth(math.ceil(newHP * currentHealthPercentage)) -- Keep relative HP
end