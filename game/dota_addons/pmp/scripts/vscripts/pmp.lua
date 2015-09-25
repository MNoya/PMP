print ('[PMP] pmp.lua' )

DISABLE_FOG_OF_WAR_ENTIRELY = false
CAMERA_DISTANCE_OVERRIDE = 1600
GOLD_PER_TICK = 5
GOLD_TICK_TIME = 7 --Same as the peon spawn time
UNSEEN_FOG_ENABLED = false
DEBUG_SPEW = 1
UNIT_FORMATION_DISTANCE = 120
INITIAL_PEONS = 6
INITIAL_GOLD = 50
INITIAL_LUMBER = 50
INITIAL_FOOD_LIMIT = 10
XP_PER_PEON = 10

TEAM_COLORS = {}
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 52, 85, 255 }   --  Blue
TEAM_COLORS[DOTA_TEAM_BADGUYS]  = { 255, 52, 85 }  	--  Red
TEAM_COLORS[DOTA_TEAM_CUSTOM_1] = { 61, 210, 150 }  --  Teal
TEAM_COLORS[DOTA_TEAM_CUSTOM_2] = { 140, 42, 244 }  --  Purple
TEAM_COLORS[DOTA_TEAM_CUSTOM_3] = { 243, 201, 9 }   --  Yellow
TEAM_COLORS[DOTA_TEAM_CUSTOM_4] = { 255, 108, 0 }   --  Orange
TEAM_COLORS[DOTA_TEAM_CUSTOM_5] = { 101, 212, 19 }  --  Green
TEAM_COLORS[DOTA_TEAM_CUSTOM_6] = { 197, 77, 168 }  --  Pink
TEAM_COLORS[DOTA_TEAM_CUSTOM_7] = { 129, 83, 54 }   --  Brown
TEAM_COLORS[DOTA_TEAM_CUSTOM_8] = { 199, 228, 13 }  --  Olive

PLAYER_COLORS = {}
PLAYER_COLORS[0] = { 52, 85, 255 }   --  Blue
PLAYER_COLORS[1]  = { 255, 52, 85 }   --  Red
PLAYER_COLORS[2] = { 61, 210, 150 }  --  Teal
PLAYER_COLORS[3] = { 140, 42, 244 }  --  Purple
PLAYER_COLORS[4] = { 243, 201, 9 }   --  Yellow
PLAYER_COLORS[5] = { 255, 108, 0 }   --  Orange
PLAYER_COLORS[6] = { 101, 212, 19 }  --  Green
PLAYER_COLORS[7] = { 197, 77, 168 }  --  Pink
PLAYER_COLORS[8] = { 129, 83, 54 }   --  Brown
PLAYER_COLORS[9] = { 199, 228, 13 }  --  Olive
PLAYER_COLORS[10] = { 105, 105, 255 }  --  Light Blue
PLAYER_COLORS[11] = { 128, 128, 128 }  --  Gray

XP_PER_LEVEL_TABLE = {
    0, 200, 500, 900, 1400, 2000, 2700, 3500, 4400, 5400, 
    6000, 6600, 7200, 7800, 8400, 9000, 9600, 10200, 10800, 11400,
    12000, 12600, 13200, 13800, 14400, 15000, 15600, 16200, 16800,
    17400, 18000, 18600, 19200, 19800, 20400, 21000, 21600, 22200,
    22800, 23400, 24000, 24600, 25200, 25800, 26400, 27000, 27600,
    28200, 28800, 29400, 30000, 30600, 31200, 31800, 32400, 33000,
    33600, 34200, 34800, 35400, 36000, 36600, 37200, 37800, 38400,
    39000, 39600, 40200, 40800, 41400, 42000, 42600, 43200, 43800
}

--------------

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function PMP:InitGameMode()
	print('[PMP] Starting to load gamemode...')

	-- Setup rules
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( false )
	GameRules:SetSameHeroSelectionEnabled( true )
	GameRules:SetHeroSelectionTime( 30 )
	GameRules:SetPreGameTime( 30 )
	GameRules:SetPostGameTime( 30 )
	GameRules:SetTreeRegrowTime( 10000.0 )
	GameRules:SetUseCustomHeroXPValues ( true )
	GameRules:SetGoldPerTick(0)
	GameRules:SetUseBaseGoldBountyOnHeroes( false ) -- Need to check legacy values
	GameRules:SetHeroMinimapIconScale( 1 )
	GameRules:SetCreepMinimapIconScale( 1 )
	GameRules:SetRuneMinimapIconScale( 1 )
	GameRules:SetFirstBloodActive( false )
  	GameRules:SetHideKillMessageHeaders( true )
    GameRules:SetGoldPerTick(GOLD_PER_TICK)
    GameRules:SetGoldTickTime(GOLD_TICK_TIME)

  	-- Set game mode rules
	GameMode = GameRules:GetGameModeEntity()        
	GameMode:SetRecommendedItemsDisabled( true )
	GameMode:SetBuybackEnabled( false )
	GameMode:SetTopBarTeamValuesOverride( true )
    GameMode:SetTopBarTeamValuesVisible( false )
	GameMode:SetUseCustomHeroLevels ( true )
	GameMode:SetUnseenFogOfWarEnabled( UNSEEN_FOG_ENABLED )	
	GameMode:SetTowerBackdoorProtectionEnabled( false )
	GameMode:SetGoldSoundDisabled( false )
	GameMode:SetRemoveIllusionsOnDeath( true )
	GameMode:SetAnnouncerDisabled( true )
	GameMode:SetLoseGoldOnDeath( false )
	GameMode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
	GameMode:SetFogOfWarDisabled( DISABLE_FOG_OF_WAR_ENTIRELY )
    GameMode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
	GameMode:SetCustomHeroMaxLevel ( 80 )

	-- Team Colors
	for team,color in pairs(TEAM_COLORS) do
        SetTeamCustomHealthbarColor(team, color[1], color[2], color[3])
    end

	-- DebugPrint
	Convars:RegisterConvar('debug_spew', tostring(DEBUG_SPEW), 'Set to 1 to start spewing debug info. Set to 0 to disable.', 0)

    if GetMapName() == "free_for_all" then
        -- 10 teams of 1 player
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_3, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_4, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_5, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_6, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_7, 1 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_8, 1 )

        GameRules.PlayersPerTeam = 1
        
    else
        -- Default to 3v3v3v3
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 3 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 3 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, 3 )
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_3, 3 )
        GameRules:EnableCustomGameSetupAutoLaunch(false)
        GameRules.PlayersPerTeam = 3
    end

    statCollection:setFlags({team_setting = GameRules.PlayersPerTeam})

	-- Event Hooks
	ListenToGameEvent('entity_killed', Dynamic_Wrap(PMP, 'OnEntityKilled'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(PMP, 'OnNPCSpawned'), self)
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(PMP, 'OnPlayerPickHero'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(PMP, 'OnGameRulesStateChange'), self)
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(PMP, 'OnConnectFull'), self)
	ListenToGameEvent('player_connect', Dynamic_Wrap(PMP, 'PlayerConnect'), self)
    ListenToGameEvent('player_disconnect', Dynamic_Wrap(PMP, 'OnDisconnect'), self)
    ListenToGameEvent('player_chat', Dynamic_Wrap(PMP, 'OnPlayerChat'), self)

	-- Filters
    GameMode:SetExecuteOrderFilter( Dynamic_Wrap( PMP, "FilterExecuteOrder" ), self )

    -- Register Listener
    CustomGameEventManager:RegisterListener( "reposition_player_camera", Dynamic_Wrap(PMP, "RepositionPlayerCamera"))
    CustomGameEventManager:RegisterListener( "update_selected_entities", Dynamic_Wrap(PMP, 'OnPlayerSelectedEntities'))
    CustomGameEventManager:RegisterListener( "building_rally_order", Dynamic_Wrap(PMP, "OnBuildingRallyOrder")) --Right click through panorama
    CustomGameEventManager:RegisterListener( "trade_order", Dynamic_Wrap(PMP, "OnTradeOrder")) --Trader
    CustomGameEventManager:RegisterListener( "set_setting", Dynamic_Wrap(PMP, "SetSetting")) --Team Options
	
    -- Lua Modifiers
    LinkLuaModifier("modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap", LUA_MODIFIER_MOTION_NONE)

	-- Allow cosmetic swapping
	SendToServerConsole( "dota_combine_models 0" )

	-- Change random seed
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
	math.randomseed(tonumber(timeTxt))

    self.vUserIds = {}
    self.vPlayerUserIds = {}

    -- Win Condition
    GameRules.StillInGame = {}

    -- Music play
    GameRules.PlayingMusic = {}

	-- KV Files
	GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
  	GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  	GameRules.HeroKV = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
  	GameRules.ItemKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")

    GameRules.APPLIER = CreateItem("item_apply_modifiers", nil, nil)
    GameRules.UPGRADER = CreateItem("item_upgrade_modifiers", nil, nil)

    -- Lumber AbilityValue, credits to zed https://github.com/zedor/AbilityValues
    Convars:RegisterCommand( "ability_values_entity", function(name, entityIndex)
        local cmdPlayer = Convars:GetCommandClient()
        local pID = cmdPlayer:GetPlayerID()

        if cmdPlayer then
            local unit = EntIndexToHScript(tonumber(entityIndex))
            if not IsValidEntity(unit) then
                return
            end
            
            if unit then
                local abilityValues = {}
                local itemValues = {}

                -- Iterate over the abilities
                for i=0,15 do
                    local ability = unit:GetAbilityByIndex(i)

                    -- If there's an ability in this slot and its not hidden, define the number to show
                    if ability and not ability:IsHidden() then
                        local lumberCost = ability:GetLevelSpecialValueFor("lumber_cost", ability:GetLevel() - 1)
                        if lumberCost then
                            table.insert(abilityValues,lumberCost)
                        else
                            table.insert(abilityValues,0)
                        end
                    end
                end

                FireGameEvent( 'ability_values_send', { player_ID = pID, 
                                                    hue_1 = -10, val_1 = abilityValues[1], 
                                                    hue_2 = -10, val_2 = abilityValues[2], 
                                                    hue_3 = -10, val_3 = abilityValues[3], 
                                                    hue_4 = -10, val_4 = abilityValues[4], 
                                                    hue_5 = -10, val_5 = abilityValues[5],
                                                    hue_6 = -10, val_6 = abilityValues[6] } )

                -- Iterate over the items
                for i=0,5 do
                    local item = unit:GetItemInSlot(i)

                    -- If there's an item in this slot, define the number to show
                    if item then
                        local cost = item:GetGoldCost(1)
                        if cost then
                            table.insert(itemValues,cost)
                        else
                            table.insert(itemValues,0)
                        end
                    else
                        table.insert(itemValues,0)
                    end
                end

                FireGameEvent( 'ability_values_send_items', { player_ID = pID, 
                                                    hue_1 = -60, bri_1 = -50, val_1 = itemValues[1], 
                                                    hue_2 = -60, bri_2 = -50, val_2 = itemValues[2], 
                                                    hue_3 = -60, bri_3 = -50, val_3 = itemValues[3], 
                                                    hue_4 = -60, bri_4 = -50, val_4 = itemValues[4], 
                                                    hue_5 = -60, bri_5 = -50, val_5 = itemValues[5],
                                                    hue_6 = -60, bri_6 = -50, val_6 = itemValues[6] } )
                
            else
                -- Hide all the values if the unit is not supposed to show any.
                FireGameEvent( 'ability_values_send', { player_ID = pID, val_1 = 0, val_2 = 0, val_3 = 0, val_4 = 0, val_5 = 0, val_6 = 0 } )
                FireGameEvent( 'ability_values_send_items', { player_ID = pID, val_1 = 0, val_2 = 0, val_3 = 0, val_4 = 0, val_5 = 0, val_6 = 0 } )
            end
        end
    end, "Change AbilityValues", 0 )

  	-- Store and update selected units of each pID
	GameRules.SELECTED_UNITS = {}

    -- Keeps the blighted gridnav positions
    GameRules.Blight = {}
  	
  	-- Starting positions
  	GameRules.StartingPositions = {}
	local targets = Entities:FindAllByName( "*starting_position" ) --Inside player_start.vmap prefab

    targets = ShuffledList(targets)

	for k,v in pairs(targets) do
		local pos_table = {}
		pos_table.position = v:GetAbsOrigin()
		pos_table.playerID = -1
		GameRules.StartingPositions[k-1] = pos_table
	end

	print('[PMP] Done loading gamemode!')
end

-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function PMP:PlayerConnect(keys)
	print('[PMP] PlayerConnect')
	--DeepPrintTable(keys)
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function PMP:OnConnectFull(keys)
    print ('[PMP] OnConnectFull')
    --DeepPrintTable(keys)

    local entIndex = keys.index+1
    -- The Player entity of the joining user
    local ply = EntIndexToHScript(entIndex)

    -- The Player ID of the joining player
    local playerID = ply:GetPlayerID()

    -- Update the user ID table with this user
    self.vUserIds[keys.userid] = ply
    self.vPlayerUserIds[playerID] = keys.userid

end

function PMP:PostLoadPrecache()
	print("[PMP] Performing Post-Load precache")
end

function PMP:OnFirstPlayerLoaded()
	print("[PMP] First Player has loaded")
end

function PMP:OnAllPlayersLoaded()
	print("[PMP] All Players have loaded into the game")
end

-- A player picked a hero
function PMP:OnPlayerPickHero(keys)
	print ('[PMP] OnPlayerPickHero')
    local heroName = keys.hero
    local hero = EntIndexToHScript(keys.heroindex)
    local player = EntIndexToHScript(keys.player)
    local playerID = player:GetPlayerID()
    local teamNumber = hero:GetTeamNumber()
    local race = GetRace(hero)
    local playerName = PlayerResource:GetPlayerName(playerID)
    if playerName == "" then playerName = "Player "..playerID end

    -- Color
    local color = PMP:ColorForTeam( teamNumber )
    PlayerResource:SetCustomPlayerColor( playerID, color[1], color[2], color[3] )

    -- Main building
    if not GameRules.StartingPositions[playerID] then 
        print("Not enough slots!")
        return
    end

    -- Add to playing list
    table.insert(GameRules.StillInGame, hero)

    local center_position = GameRules.StartingPositions[playerID].position
    hero.garage = CreateUnitByName(race.."_garage", center_position, false, hero, hero, teamNumber)
    hero.garage:SetOwner(hero)
    hero.garage:SetControllableByPlayer(playerID, true)
    hero.garage.rally_point = center_position
    Timers:CreateTimer(0.1, function() 
        ApplyModifier(hero.garage, "modifier_show_health_bar")
        hero.garage:SetCustomHealthLabel( playerName, color[1], color[2], color[3])  -- Add a label on the base
    end)

    -- Undead effects
    if race == "undead" then
        CreateBlight(center_position)
    end

    Timers:CreateTimer(1/30, function() 
        NewSelection(hero.garage)
        PlayerResource:SetCameraTarget(playerID, hero.garage)
        Timers:CreateTimer(2/30, function() PlayerResource:SetCameraTarget(playerID, nil) end)
    end)

    -- Apply 4 layers of invulnerability from towers
    ApplyModifier(hero.garage, "modifier_invulnerability_layer")
    hero.garage:SetModifierStackCount("modifier_invulnerability_layer", GameRules.APPLIER, 4)
    hero.invulnCount = 4

    -- The main hero is an invulnerable fake just used to get global upgrades
    center_position.z = 0
    hero:SetAbsOrigin(center_position)
    hero:AddNoDraw()

    -- Upgrade Shop
    local shopEnt = Entities:FindByNameWithin(nil, "*shop_position", center_position, 1000)
    hero.pimpery = CreateUnitByName(race.."_pimpery", shopEnt:GetAbsOrigin(), false, hero, hero, teamNumber)
    hero.pimpery:SetOwner(hero)
    hero.pimpery:SetControllableByPlayer(playerID, true)
    hero.pimpery:SetAngles(0, -90, 0)

    PMP:GiveItemUpgrades(hero.pimpery)

	-- Towers - 1 on each corner
    hero.towers = {}
    local towerEnts = Entities:FindAllByNameWithin("*tower_position", center_position, 1200)
    for k,tower in pairs(towerEnts) do
        local tower = CreateUnitByName(race.."_tower", tower:GetAbsOrigin(), false, hero, hero, teamNumber)
        tower:SetOwner(hero)
        tower:SetControllableByPlayer(playerID, true)
        table.insert(hero.towers, tower)
    end

	-- Barricades - 3 on each side
    print("[PMP] Setting Up Barricades")
    hero.barricade_positions = {}
    hero.barricades = {}
    local Barricades = GameRules.Barricades
    local randomN = Barricades["Random"]

    local barricadeEntsX = Entities:FindAllByNameWithin("*barricade_positionX", center_position, 1200)
    for k,v in pairs(barricadeEntsX) do
        local pos = v:GetAbsOrigin()

        for i=-1,1 do
            local nBarricade = tostring(RandomInt(1, randomN))
            local posX = pos+Vector(i*70,0,0)
            local barricade = CreateUnitByName("barricade", posX, false, hero, hero, teamNumber)
            barricade:SetModel(Barricades[nBarricade]["Model"])
            barricade:SetModelScale(Barricades[nBarricade]["Scale"])
            barricade:SetAngles(0, RandomInt(0,360), 0)
            barricade:SetAbsOrigin(GetGroundPosition(posX, barricade))
            barricade:SetOwner(hero)
            table.insert(hero.barricades, barricade)
        end

        table.insert(hero.barricade_positions, pos)
    end

    local barricadeEntsY = Entities:FindAllByNameWithin("*barricade_positionY", center_position, 1200)
    for k,v in pairs(barricadeEntsY) do
        local pos = v:GetAbsOrigin()

        for i=-1,1 do
            local nBarricade = tostring(RandomInt(1, randomN))
            local posY = pos+Vector(0,i*70,0)
            local barricade = CreateUnitByName("barricade", posY, false, hero, hero, teamNumber)
            barricade:SetModel(Barricades[nBarricade]["Model"])
            barricade:SetModelScale(Barricades[nBarricade]["Scale"])
            barricade:SetAngles(0, RandomInt(0,360), 0)
            barricade:SetAbsOrigin(GetGroundPosition(posY, barricade))
            table.insert(hero.barricades, barricade)
        end

        table.insert(hero.barricade_positions, pos)
    end

    -- Tracking
    hero.lumber = 0
    hero.food_used = 0
    hero.food_limit = 0
    hero.spawn_rate = 1

    hero.super_peons_used = 0
    hero.barricades_used = 0
    hero.repairs_used = 0

    hero.gold_earned = 0
    hero.lumber_earned = 0

    hero.Upgrades = {}
    hero.Upgrades["weapon"] = 0
    hero.Upgrades["helm"] = 0
    hero.Upgrades["armor"] = 0
    hero.Upgrades["wings"] = 0
    hero.Upgrades["health"] = 0  

    hero.Upgrades["critical_strike"] = 0
    hero.Upgrades["stun_hit"] = 0
    hero.Upgrades["poisoned_weapons"] = 0
    hero.Upgrades["pulverize"] = 0
    hero.Upgrades["dodge"] = 0
    hero.Upgrades["spiked_armor"] = 0

    hero.Upgrades["pimp_damage"] = 0
    hero.Upgrades["pimp_armor"] = 0
    hero.Upgrades["pimp_speed"] = 0
    hero.Upgrades["pimp_regen"] = 0

    --PMP:PrintUpgrades(playerID)

    -- Set Resources
    Timers:CreateTimer(function()
        SetGold(playerID, INITIAL_GOLD)
        SetLumber(playerID, INITIAL_LUMBER)
        SetFoodUsed(playerID, 0)
        SetFoodLimit(playerID, INITIAL_FOOD_LIMIT)

        if Convars:GetBool('developer') then 
            SetGold(playerID, 99999)
            SetLumber(playerID, 99999)
            --SetFoodLimit(playerID, 100)
        end

        -- Set initial units
        hero.units = {}
        for i=1,INITIAL_PEONS do
            local unit = CreateUnitByName(race, center_position, true, hero, hero, hero:GetTeamNumber())
            unit:SetOwner(hero)
            unit:SetControllableByPlayer(playerID, true)
            unit:AddNewModifier(unit, nil, "modifier_movespeed_cap", {})
            FindClearSpaceForUnit(unit, center_position, true)
            ModifyFoodUsed(playerID, 1)
            table.insert(hero.units, unit)
            unit.pmp = true
        end
    end)
end

ITEM_UPGRADE_LIST = 
{ 
    "item_upgrade_critical_strike1",
    "item_upgrade_stun_hit1",
    "item_upgrade_poisoned_weapons1",
    --"item_upgrade_pulverize1",
    "item_upgrade_dodge1",
    "item_upgrade_spiked_armor1"
}

function PMP:GiveItemUpgrades( unit )
    for i=1,6 do
        print("Adding",ITEM_UPGRADE_LIST[i])
        unit:AddItem(CreateItem(ITEM_UPGRADE_LIST[i], unit, unit))
    end
end

-- An NPC has spawned somewhere in game. This includes heroes
function PMP:OnNPCSpawned(keys)
	--print("[PMP] NPC Spawned")
	--DeepPrintTable(keys)
	local npc = EntIndexToHScript(keys.entindex)

	if npc:IsRealHero() and npc.bFirstSpawned == nil then
		npc.bFirstSpawned = true
		PMP:OnHeroInGame(npc)
	end

    --ApplyModifier(npc, "modifier_attackable")
end

function PMP:OnHeroInGame(hero)
	local hero_name = hero:GetUnitName()
	print("[PMP] OnHeroInGame "..hero_name)

    ClearAbilities(hero)
    TeachAbility(hero, "hide_hero", 1)

    -- Global upgrade abilities
    hero:AddAbility("pimp_damage")
    hero:AddAbility("pimp_armor")
    hero:AddAbility("pimp_speed")
    hero:AddAbility("pimp_regen")

    Timers:CreateTimer(1, function()
        hero:AddNoDraw()
    end)
end

function PMP:OnGameInProgress()
	print("[PMP] The game has officially begun")

    GameRules:SendCustomMessage("Welcome to <font color='#FF0000'>Pimp My Peon</font>!", 0, 0)

    Timers:CreateTimer(1, function() 
        PMP:CheckWinCondition()
        return 1
    end)
end

gamestates =
{
    [0] = "DOTA_GAMERULES_STATE_INIT",
    [1] = "DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD",
    [2] = "DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP",
    [3] = "DOTA_GAMERULES_STATE_HERO_SELECTION",
    [4] = "DOTA_GAMERULES_STATE_STRATEGY_TIME",
    [5] = "DOTA_GAMERULES_STATE_TEAM_SHOWCASE",
    [6] = "DOTA_GAMERULES_STATE_PRE_GAME",
    [7] = "DOTA_GAMERULES_STATE_GAME_IN_PROGRESS",
    [8] = "DOTA_GAMERULES_STATE_POST_GAME",
    [9] = "DOTA_GAMERULES_STATE_DISCONNECT"
}

-- The overall game state has changed
function PMP:OnGameRulesStateChange(keys)
	local newState = GameRules:State_Get()

	print("[PMP] GameRules State Changed: ",gamestates[newState])
			
	if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
        PMP:PostLoadPrecache()
        PMP:OnAllPlayersLoaded()
	elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		PMP:OnGameInProgress()
	end
end

-- An entity died
function PMP:OnEntityKilled( event )
	--print( '[PMP] OnEntityKilled' )

	local killed = EntIndexToHScript(event.entindex_killed)
	local attacker
	if event.entindex_attacker then
		attacker = EntIndexToHScript(event.entindex_attacker)
	end

    if killed:IsHero() then
        return
    end

    -- Killed credentials
    local killed_player = killed:GetPlayerOwner()
    local killed_playerID = killed:GetPlayerOwnerID()
    local killed_teamNumber = killed:GetTeamNumber()
    local killed_hero = PlayerResource:GetSelectedHeroEntity(killed_playerID)

    -- Attacker credentials
    local attacker_player = attacker and attacker:GetPlayerOwner()
    local attacker_playerID = attacker and attacker:GetPlayerOwnerID()
    local attacker_teamNumber = attacker and attacker:GetTeamNumber()
    local attacker_hero = attacker_playerID and PlayerResource:GetSelectedHeroEntity(attacker_playerID)

    -- Garage killed
    if IsCityCenter(killed) then
        killed:AddNoDraw()
        print("Garage Down for player",killed_playerID)

        SendDefeatedMessage(attacker_playerID,killed_playerID)

        PMP:MakePlayerLose(killed_playerID)

    -- Tower killed
    elseif IsCustomTower(killed) then

        print("Tower Killed for playerID ",killed_playerID)

        -- Table cleanup
        local tower_table = GetPlayerTowers(killed_playerID)
        local unit_index = getIndexTable(tower_table, killed)
        if unit_index then
            print("Tower Removed from Table")
            table.remove(tower_table, unit_index)
        end

        ParticleManager:CreateParticle("particles/newplayer_fx/npx_wood_break.vpcf", PATTACH_ABSORIGIN, killed)
        killed:AddNoDraw()

        ReduceInvulnerabilityCount(killed_hero)

        print("Reduced Invulnerability count of playerID ",killed_playerID)    

    -- Pimp Creature killed
    elseif IsPimpUnit(killed) then
       
        -- Remove prop wearables
        Timers:CreateTimer(4, function()
            ClearPropWearables(killed)
        end)

        -- Table cleanup
        local unit_table = GetPlayerUnits(killed_playerID)
        local unit_index = getIndexTable(unit_table, killed)
        if unit_index then
            table.remove(unit_table, unit_index)

            -- Substract the Food Used
            local food = GetFoodCost(killed:GetUnitName())
            ModifyFoodUsed(killed_playerID, -food)
        end

        -- If not denied
        if killed_teamNumber ~= attacker_teamNumber then
            
            -- Give experience globally to the attacker hero
            if attacker_hero then
                attacker_hero:AddExperience(XP_PER_PEON, true, true)
                attacker_hero:IncrementKills(1) 
            end

            killed_hero:IncrementDeaths(1)
            
            --Add Score
        end
    end

    -- Give lumber bounty to the attacker (unless denied)
    if attacker_playerID and attacker_playerID ~= -1 and killed_teamNumber ~= attacker_teamNumber then
        local lumber_bounty = GetLumberBounty(killed)
        ModifyLumber(attacker_playerID, lumber_bounty)
        PopupLumber(killed, lumber_bounty, attacker_teamNumber)

        attacker_hero.lumber_earned = attacker_hero.lumber_earned + lumber_bounty
    end
end

function PMP:MakePlayerLose( playerID )
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local playerGarage = GetPlayerCityCenter(playerID)
    local playerUnits = GetPlayerUnits(playerID)
    local playerShop = GetPlayerShop(playerID)
    local playerBarricades = GetPlayerBarricades(playerID)

    -- Clear the Still In Game table
    local unit_index = getIndexTable(GameRules.StillInGame, hero)
    if unit_index then
        print("MakePlayerLose",playerID)
        table.remove(GameRules.StillInGame, unit_index)
    end

    -- Clear player units
    for k,unit in pairs(playerUnits) do
        Timers:CreateTimer(1/30 * k, function()
            if IsValidAlive(unit) then
                unit:ForceKill(false)
            end
        end)
    end

    -- Clear barricades
    for k,barricade in pairs(playerBarricades) do
        UTIL_Remove(barricade)
    end 

    -- Clear player shop and garage
    if IsValidAlive(playerShop) then
        UTIL_Remove(playerShop)
    end

    if IsValidAlive(playerGarage) then
        UTIL_Remove(playerGarage)
    end

    -- Give a ghost peon unit to scout
    if hero then
        -- Fx
        local explosion1 = ParticleManager:CreateParticle("particles/radiant_fx2/frostivus_wking_altar_smokering.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
        local explosion2 = ParticleManager:CreateParticle("particles/dire_fx/bad_barracks001_ranged_destroy.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)

        local origin = hero:GetAbsOrigin()
        hero.ghost = CreateUnitByName("peon_ghost", origin, false, hero, hero, hero:GetTeamNumber())
        hero.ghost:SetOwner(hero)
        hero.ghost:SetControllableByPlayer(playerID, true)
        hero.lost = true
        hero:ForceKill(true)
        hero:SetRespawnsDisabled(true)

        local playerName = PlayerResource:GetPlayerName(playerID)
        if playerName == "" then playerName = "Player "..playerID end
        GameRules:SendCustomMessage(playerName.." was defeated", 0, 0)

        -- Send stats
        statCollection:submitRound({})
    end
end

-- Cleanup a player when they leave
function PMP:OnDisconnect(keys)
    local name = keys.name
    local networkid = keys.networkid
    local reason = keys.reason
    local userid = keys.userid

    --[[if self.vUserIds[userid] then
        local playerID = self.vUserIds[userid]:GetPlayerID()

        PMP:MakePlayerLose( playerID )
    end]]
end

-- Check for win condition
function PMP:CheckWinCondition()
    local winnerTeamID = nil

    -- Don't end single player lobbies
    if PlayerResource:GetPlayerCount() == 1 then
        return
    end

    -- Check if all the heroes still in game belong to the same team
    for k,hero in pairs(GameRules.StillInGame) do
        local teamNumber = hero:GetTeamNumber()
        if not winnerTeamID then
            winnerTeamID = teamNumber
        elseif winnerTeamID ~= teamNumber then
            return
        end
    end    

    if winnerTeamID then
        print(winnerTeamID.." is the Winner")

        GameRules:SetGameWinner(winnerTeamID)
        PMP:PrintWinMessageForTeam(winnerTeamID)
    end
end

-- Player changed selection
function PMP:OnPlayerSelectedEntities( event )
	local pID = event.pID

	GameRules.SELECTED_UNITS[pID] = event.selected_entities

    FireGameEvent( 'ability_values_force_check', { player_ID = pID })
end

-- Teams Blue, Red, Purple, Orange, Yellow and Green
MULTI_TEAM_MAP_TEAMS = {
    DOTA_TEAM_GOODGUYS,
    DOTA_TEAM_BADGUYS,
    DOTA_TEAM_CUSTOM_2,
    DOTA_TEAM_CUSTOM_3,
    DOTA_TEAM_CUSTOM_4,
    DOTA_TEAM_CUSTOM_5
}

TEAM_OPTIONS = { [1] = 2, [2] = 3, [3] = 4, [4] = 6, }

function PMP:SetSetting( event )
    local setting = event.setting
    local value = tonumber(event.value)

    if setting == "TeamRow" then
        local playersPerTeam = TEAM_OPTIONS[value]
        local teamCount = 12 / playersPerTeam
        for i=1,teamCount do
            GameRules:SetCustomGameTeamMaxPlayers( MULTI_TEAM_MAP_TEAMS[i], playersPerTeam )
        end
        for i=teamCount+1,6 do
           GameRules:SetCustomGameTeamMaxPlayers( MULTI_TEAM_MAP_TEAMS[i], 0 )
        end

        GameRules.PlayersPerTeam = TEAM_OPTIONS[value]

        statCollection:setFlags({team_setting = GameRules.PlayersPerTeam})
    end

    -- Update UI on the clients
    CustomGameEventManager:Send_ServerToAllClients("setting_changed", { setting = setting, value = value})
end

function PMP:RepositionPlayerCamera( event )
	local pID = event.pID
	local entIndex = event.entIndex
	local entity = EntIndexToHScript(entIndex)
	if entity and IsValidEntity(entity) then
		PlayerResource:SetCameraTarget(pID, entity)
		Timers:CreateTimer(function()
			PlayerResource:SetCameraTarget(pID, nil)
		end)
	end
end

-- Returns an Int with the number of teams with valid players in them
function PMP:GetTeamCount()
	local teamCount = 0
	for i=DOTA_TEAM_FIRST,DOTA_TEAM_CUSTOM_MAX do
		local playerCount = PlayerResource:GetPlayerCountForTeam(i)
		if playerCount > 0 then
			teamCount = teamCount + 1
			print("  Team ["..i.."] has "..playerCount.." players")
		end
	end
	return teamCount
end

-- This should only be called when all teams but one are defeated
-- Returns the first player with a building left standing
function PMP:GetWinningTeam()
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayerID(playerID) then
			local player = PlayerResource:GetPlayer(playerID)
			if #player.structures > 0 then
				return player:GetTeamNumber()
			end
		end
	end
end

function PMP:PrintDefeateMessageForTeam( teamID )
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayerID(playerID) then
			local player = PlayerResource:GetPlayer(playerID)
			if player:GetTeamNumber() == teamID then
				local playerName = PlayerResource:GetPlayerName(playerID)
				if playerName == "" then playerName = "Player "..playerID end
				GameRules:SendCustomMessage(playerName.." was defeated", 0, 0)
			end
		end
	end
end

function PMP:PrintWinMessageForTeam( teamID )
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayerID(playerID) then
			local player = PlayerResource:GetPlayer(playerID)
			if player and player:GetTeamNumber() == teamID then
				local playerName = PlayerResource:GetPlayerName(playerID)
				if playerName == "" then playerName = "Player "..playerID end
				GameRules:SendCustomMessage(playerName.." was victorious!", 0, 0)
			end
		end
	end
end

function PMP:ColorForTeam( teamID )
    local color = TEAM_COLORS[teamID]
    if color == nil then
        color = { 255, 255, 255 } -- default to white
    end
    return color
end

function PMP:ColorForPlayerID( pID )
    local color = PLAYER_COLORS[pID]
    if color == nil then
        color = { 255, 255, 255 } -- default to white
    end
    return color
end