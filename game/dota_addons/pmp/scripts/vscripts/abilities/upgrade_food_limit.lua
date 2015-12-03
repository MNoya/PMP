upgrade_food_limit = class ({})

function upgrade_food_limit:OnSpellStart()
    local ability = self

    local caster = ability:GetCaster()
    local level = ability:GetLevel()
    local pID = caster:GetPlayerOwnerID()

    ModifyFoodLimit(pID, 1)

    local maxLevel = ability:GetMaxLevel()
    if level == maxLevel then
        ability:SetHidden(true)
        
        Sounds:EmitSoundOnClient(pID, "Announcer.Upgrade.Food.Max")
    else
        Sounds:EmitSoundOnClient(pID, "Announcer.Upgrade.Food")

        ability:SetLevel(level + 1)
    end

    return 
end

function upgrade_food_limit:OnToggle()
    if self:GetToggleState() then
        self:GetCaster():GetOwner():ModifyGold(self:GetGoldCost(self:GetLevel()), false, 0)
    end
end

function upgrade_food_limit:GetBehavior()
    local behav = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    local caster = self:GetCaster()

    if caster:HasModifier("modifier_tutorial") then      
        return behav + DOTA_ABILITY_BEHAVIOR_TOGGLE
    else
        return behav
    end
end

function upgrade_food_limit:GetGoldCost()
    local ability = self

    local baseGoldCost = 20
    local extraGoldPerLevel = 10
    local level = ability:GetLevel()
    
    local newGoldCost = baseGoldCost + (level-1) * extraGoldPerLevel
    
    -- Restrict gold to 999 (max number displayed)
    if newGoldCost >= 1000 then
        newGoldCost = 999
    end

    return (newGoldCost)
end