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
    else
        ability:SetLevel(level + 1)
    end

    return 
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