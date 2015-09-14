-- Contains general mechanics used extensively thourought different scripts

------------------------------------------------
--                Error Messages              --
------------------------------------------------

function SendErrorMessage( pID, string )
    Notifications:ClearBottom(pID)
    Notifications:Bottom(pID, {text=string, style={color='#E62020'}, duration=2})
    EmitSoundOnClient("General.Cancel", PlayerResource:GetPlayer(pID))
end

------------------------------------------------
--             Resource functions            --
------------------------------------------------

-- Gets
function GetGold( pID )
    PlayerResource:GetGold(pID)
end

function GetLumber( pID )
    local hero = PlayerResource:GetSelectedHeroEntity(pID) -- Values are stored in the hero handle
    
    return hero.lumber
end

function GetFoodUsed( pID )
    local hero = PlayerResource:GetSelectedHeroEntity(pID) -- Values are stored in the hero handle
    
    return hero.food_used
end

function GetFoodLimit( pID )
    local hero = PlayerResource:GetSelectedHeroEntity(pID) -- Values are stored in the hero handle
    
    return hero.food_limit
end

function GetSpawnRate( pID )
    local hero = PlayerResource:GetSelectedHeroEntity(pID)

    return hero.spawn_rate
end

-- Sets
function SetGold( pID, value )
    local hero = PlayerResource:GetSelectedHeroEntity(pID)
    hero:SetGold(value, false)
end

function SetLumber( pID, value )
    local player = PlayerResource:GetPlayer(pID)
    local hero = PlayerResource:GetSelectedHeroEntity(pID)
    
    hero.lumber = value
    CustomGameEventManager:Send_ServerToPlayer(player, "player_lumber_changed", { lumber = math.floor(hero.lumber) })
end

function SetFoodUsed( pID, value )
    local player = PlayerResource:GetPlayer(pID)
    local hero = PlayerResource:GetSelectedHeroEntity(pID)
    local race = GetRace(hero)

    hero.food_used = value
    CustomGameEventManager:Send_ServerToPlayer(player, 'player_food_changed', { food_used = hero.food_used, food_limit = hero.food_limit, race = race}) 
end

function SetFoodLimit( pID, value )
    local player = PlayerResource:GetPlayer(pID)
    local hero = PlayerResource:GetSelectedHeroEntity(pID)
    local race = GetRace(hero)
    
    hero.food_limit = value
    CustomGameEventManager:Send_ServerToPlayer(player, 'player_food_changed', { food_used = hero.food_used, food_limit = hero.food_limit, race = race }) 
end

-- Spawn rate starts at 1 and can be upgraded up to 10 per time
function SetSpawnRate( pID, value )
    local hero = PlayerResource:GetSelectedHeroEntity(pID)

    hero.spawn_rate = value
end

-- Modifies +/- value
function ModifyLumber( pID, lumber_value )
    local current_lumber = GetLumber(pID)

    if lumber_value == 0 then return end
    if lumber_value > 0 then
        SetLumber(pID, current_lumber + lumber_value)        
    else
        if PlayerHasEnoughLumber( pID, math.abs(lumber_value) ) then
            SetLumber(pID, current_lumber + lumber_value)
        end
    end
end

function ModifyGold( pID, gold_value )
    PlayerResource:ModifyGold(pID, gold_value, true, 0)
end

function ModifyFoodUsed( pID, food_used_value )
    local current_food_used = GetFoodUsed(pID)

    SetFoodUsed(pID, current_food_used + food_used_value)
end

function ModifyFoodLimit( pID, food_limit_value )
    local current_food_limit = GetFoodLimit(pID)

    SetFoodLimit(pID, current_food_limit + food_limit_value)
end

function ModifySpawnRate( pID, spawn_rate_value )
    local current_spawn_rate = GetSpawnRate(pID)

    SetSpawnRate(pID, current_spawn_rate + spawn_rate_value)
end

-- Booleans
function PlayerHasEnoughGold( pID, gold_cost )
    local hero = PlayerResource:GetSelectedHeroEntity(pID)
    local gold = hero:GetGold()

    return (not gold_cost or gold > gold_cost) or (SendErrorMessage(pID, "#error_not_enough_gold") and false)
end

function PlayerHasEnoughLumber( pID, lumber_cost )
    local lumber = GetLumber(pID)

    return (not lumber_cost or lumber > lumber_cost) or (SendErrorMessage(pID, "#error_not_enough_lumber") and false)
end

function PlayerHasEnoughFood( pID, food_cost )
    local food_limit = GetFoodLimit(pID)
    local food_used = GetFoodUsed(pID)

    return (food_used + food_cost <= food_limit)
end

-- Returns the FoodCost key of a unit by name
function GetFoodCost( unit_name )
    local unit_table = GameRules.HeroKV[unit_name] or GameRules.UnitKV[unit_name]
    return unit_table and unit_table["FoodCost"] or 0
end

function GetLumberBounty( unit )
    local unit_name = unit:GetUnitName()
    local unit_table = GameRules.UnitKV[unit_name]
    return unit_table and unit_table["BountyLumber"] or 0
end


------------------------------------------------
--               Boolean checks               --
------------------------------------------------

function IsCityCenter( unit )
    return (unit:GetUnitLabel() == "city_center")
end

function IsCustomBuilding( unit )
    local ability_building = unit:FindAbilityByName("ability_building")
    local ability_tower = unit:FindAbilityByName("ability_tower")
    if ability_building or ability_tower then
        return true
    else
        return false
    end
end

function IsCustomTower( unit )
    return unit:HasAbility("ability_tower")
end

function IsValidAlive( unit )
    return unit and IsValidEntity(unit) and unit:IsAlive()
end

-- Leaders have "_leader" in their name
function IsLeaderUnit( unit )
    local unit_name = unit:GetUnitName()
    return (string.match(unit_name,"_leader"))
end

-- Super Peon have "super_" in their name
function IsSuperPeon( unit )
    local unit_name = unit:GetUnitName()
    return (string.match(unit_name,"super_"))
end

------------------------------------------------
--             Selection functions            --
------------------------------------------------
function AddUnitToSelection( unit )
    local player = unit:GetPlayerOwner()
    CustomGameEventManager:Send_ServerToPlayer(player, "add_to_selection", { ent_index = unit:GetEntityIndex() })
end

function RemoveUnitFromSelection( unit )
    local player = unit:GetPlayerOwner()
    local ent_index = unit:GetEntityIndex()
    CustomGameEventManager:Send_ServerToPlayer(player, "remove_from_selection", { ent_index = unit:GetEntityIndex() })
end

function NewSelection( unit )
    local player = unit:GetPlayerOwner()
    local ent_index = unit:GetEntityIndex()
    CustomGameEventManager:Send_ServerToPlayer(player, "new_selection", { ent_index = unit:GetEntityIndex() })
end

function GetSelectedEntities( playerID )
    return GameRules.SELECTED_UNITS[playerID]
end

function IsCurrentlySelected( unit )
    local entIndex = unit:GetEntityIndex()
    local playerID = unit:GetPlayerOwnerID()
    local selectedEntities = GetSelectedEntities( playerID )
    for _,v in pairs(selectedEntities) do
        if v==entIndex then
            return true
        end
    end
    return false
end

-- Force-check the game event
function UpdateSelectedEntities()
    FireGameEvent("dota_player_update_selected_unit", {})
end

function GetMainSelectedEntity( playerID )
    if GameRules.SELECTED_UNITS[playerID]["0"] then
        return EntIndexToHScript(GameRules.SELECTED_UNITS[playerID]["0"])
    end
    return nil
end

----------------------------------------------

function GetOriginalModelScale( unit )
    local unit_name = unit:GetUnitName()
    local unit_table = unit:IsHero() and GameRules.HeroKV[unit_name] or GameRules.UnitKV[unit_name]
    return unit_table and unit_table["ModelScale"] or unit:GetModelScale()
end

function GetRangedProjectileName( unit )
    local unit_name = unit:GetUnitName()
    local unit_table = unit:IsHero() and GameRules.HeroKV[unit_name] or GameRules.UnitKV[unit_name]
    return unit_table and unit_table["ProjectileModel"] or ""
end

------------------------------------------------
--               Global item applier          --
------------------------------------------------
function ApplyModifier( unit, modifier_name )
    GameRules.APPLIER:ApplyDataDrivenModifier(unit, unit, modifier_name, {})
end


------------------------------------------------
--               Layout manipulation          --
------------------------------------------------

function SetAbilityLayout( unit, layout_size )
    unit:RemoveModifierByName("modifier_ability_layout4")
    unit:RemoveModifierByName("modifier_ability_layout5")
    unit:RemoveModifierByName("modifier_ability_layout6")
    
    ApplyModifier(unit, "modifier_ability_layout"..layout_size)
end

function AdjustAbilityLayout( unit )
    local required_layout_size = GetVisibleAbilityCount(unit)

    if required_layout_size > 6 then
        required_layout_size = 6
    elseif required_layout_size < 4 then
        required_layout_size = 4
    end

    SetAbilityLayout(unit, required_layout_size)
end

function GetVisibleAbilityCount( unit )
    local count = 0
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability and not ability:IsHidden() then
            count = count + 1
            ability:MarkAbilityButtonDirty()
        end
    end
    return count
end

function FindAbilityWithName( unit, ability_name_section )
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability and string.match(ability:GetAbilityName(), ability_name_section) then
            return ability
        end
    end
end

function GetAbilityOnVisibleSlot( unit, slot )
    local visible_slot = 0
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability and not ability:IsHidden() then
            visible_slot = visible_slot + 1
            if visible_slot == slot then
                return ability
            end
        end
    end
end

----------------------------------------------

--Modify Gold/Lumber should handle 0 value if they aren't doing it already
--Get Gold/Lumber Cost should handle nil value (default to 0)
function ReduceInvulnerabilityCount( hero )
    hero.invulnCount = hero.invulnCount - 1
    hero.garage:SetModifierStackCount("modifier_invulnerability_layer", GameRules.APPLIER, hero.invulnCount)

    if hero.invulnCount == 0 then
        hero.garage:RemoveModifierByName("modifier_invulnerability_layer")
    end
end

--------------------------------------------

function GetPlayerUnits( playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)

    return hero.units
end

function GetPlayerTowers( playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)

    return hero.towers
end

function GetPlayerBarricades( playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local barricades = {}
    for k,v in pairs(hero.barricades) do
        if IsValidAlive(v) then
            table.insert(barricades, v)
        end
    end

    print("Hero has ",#barricades,"barricades")
    hero.barricades = barricades

    return hero.barricades
end


function GetPlayerShop( playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)

    return hero.pimpery
end

function GetPlayerCityCenter( playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)

    return hero.garage
end

function GetPlayerBuildings( playerID )
    local buildings = {}

    local towers = GetPlayerTowers(playerID)
    for k,v in pairs(towers) do
        if IsValidAlive(v) then
            table.insert(buildings, v)
        end
    end

    local shop = GetPlayerShop( playerID )
    if IsValidAlive(shop) then
        table.insert(buildings, shop)
    end

    table.insert(buildings, GetPlayerCityCenter(playerID))

    return buildings
end

--------------------------------------------

function GetItemSlot( unit, target_item )
    for itemSlot = 0,5 do
        local item = unit:GetItemInSlot(itemSlot)
        if item and item == target_item then
            return itemSlot
        end
    end
    return -1
end

--------------------------------------------

function TeachAbility( unit, ability_name, level )
    if not level then level = 1 end
    if GameRules.AbilityKV[ability_name] then
        unit:AddAbility(ability_name)
        local ability = unit:FindAbilityByName(ability_name)
        if ability then
            ability:SetLevel(tonumber(level))
            return ability
        end
    else
        --print("ERROR, failed to teach ability "..ability_name)
        return nil
    end
end

function PrintAbilities( unit )
    print("List of Abilities in "..unit:GetUnitName())
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability then print(i.." - "..ability:GetAbilityName()) end
    end
    print("---------------------")
end

function ClearAbilities( unit )
    for i=0,15 do
        local ability = unit:GetAbilityByIndex(i)
        if ability then
            unit:RemoveAbility(ability:GetAbilityName())
        end
    end
end

--------------------------------------------

function GetRace( unit )
    local pID = unit:GetPlayerOwnerID()
    local hero = PlayerResource:GetSelectedHeroEntity(pID)
    local hero_name = hero:GetName()

    return GameRules.HeroKV[hero_name]["Race"]
end

--------------------------------------------