 print ('[PMP] pmp.lua' )

DISABLE_FOG_OF_WAR_ENTIRELY = false
CAMERA_DISTANCE_OVERRIDE = 1700
GOLD_PER_TICK = 5
GOLD_TICK_TIME = 7 --Same as the peon spawn time
UNSEEN_FOG_ENABLED = false
DEBUG_SPEW = 1
UNIT_FORMATION_DISTANCE = 120
INITIAL_PEONS = 6
INITIAL_GOLD = 50
INITIAL_LUMBER = 50
INITIAL_FOOD_LIMIT = 10

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
	GameRules:SetPreGameTime( 0 )
	GameRules:SetPostGameTime( 60 )
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
	GameMode:SetTopBarTeamValuesOverride ( true )
	GameMode:SetTopBarTeamValuesVisible( true )
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

	-- Event Hooks
	ListenToGameEvent('entity_killed', Dynamic_Wrap(PMP, 'OnEntityKilled'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(PMP, 'OnNPCSpawned'), self)
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(PMP, 'OnPlayerPickHero'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(PMP, 'OnGameRulesStateChange'), self)
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(PMP, 'OnConnectFull'), self)
	ListenToGameEvent('player_connect', Dynamic_Wrap(PMP, 'PlayerConnect'), self)
    ListenToGameEvent('player_chat', Dynamic_Wrap(PMP, 'OnPlayerChat'), self)

	-- Filters
    GameMode:SetExecuteOrderFilter( Dynamic_Wrap( PMP, "FilterExecuteOrder" ), self )

    -- Register Listener
    CustomGameEventManager:RegisterListener( "reposition_player_camera", Dynamic_Wrap(PMP, "RepositionPlayerCamera"))
    CustomGameEventManager:RegisterListener( "update_selected_entities", Dynamic_Wrap(PMP, 'OnPlayerSelectedEntities'))
    CustomGameEventManager:RegisterListener( "building_rally_order", Dynamic_Wrap(PMP, "OnBuildingRallyOrder")) --Right click through panorama
	
	-- Allow cosmetic swapping
	SendToServerConsole( "dota_combine_models 0" )

	-- Change random seed
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
	math.randomseed(tonumber(timeTxt))

	self.bSeenWaitForPlayers = false
    self.vUserIds = {}

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
                --and (unit:GetUnitName() == "human_peasant"
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
                        local lumberCost = item:GetSpecialValueFor("lumber_cost")
                        if lumberCost then
                            table.insert(itemValues,lumberCost)
                        else
                            table.insert(itemValues,0)
                        end
                    end
                end

                FireGameEvent( 'ability_values_send_items', { player_ID = pID, 
                                                    hue_1 = 0, val_1 = itemValues[1], 
                                                    hue_2 = 0, val_2 = itemValues[2], 
                                                    hue_3 = 0, val_3 = itemValues[3], 
                                                    hue_4 = 0, val_4 = itemValues[4], 
                                                    hue_5 = 0, val_5 = itemValues[5],
                                                    hue_6 = 0, val_6 = itemValues[6] } )
                
            else
                -- Hide all the values if the unit is not supposed to show any.
                FireGameEvent( 'ability_values_send', { player_ID = pID, val_1 = 0, val_2 = 0, val_3 = 0, val_4 = 0, val_5 = 0, val_6 = 0 } )
                FireGameEvent( 'ability_values_send_items', { player_ID = pID, val_1 = 0, val_2 = 0, val_3 = 0, val_4 = 0, val_5 = 0, val_6 = 0 } )
            end
        end
    end, "Change AbilityValues", 0 )

  	-- Store and update selected units of each pID
	GameRules.SELECTED_UNITS = {}
  	
  	-- Starting positions
  	GameRules.StartingPositions = {}
	local targets = Entities:FindAllByName( "*starting_position" ) --Inside player_start.vmap prefab
	for k,v in pairs(targets) do
		local pos_table = {}
		pos_table.position = v:GetOrigin()
		pos_table.playerID = -1
		GameRules.StartingPositions[k-1] = pos_table
	end

	print('[PMP] Done loading gamemode!\n\n')
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
    local heroName = keys.hero -- This determines the race
    local hero = EntIndexToHScript(keys.heroindex)
    local player = EntIndexToHScript(keys.player)
    local playerID = player:GetPlayerID()
    local teamNumber = hero:GetTeamNumber()

    -- Main building
    local center_position = GameRules.StartingPositions[playerID].position
    hero.garage = CreateUnitByName("peon_garage", center_position, false, hero, hero, teamNumber)
    hero.garage:SetOwner(hero)
    hero.garage:SetControllableByPlayer(playerID, true)
    hero.garage.rally_point = center_position

    Timers:CreateTimer(1/30, function() NewSelection(hero.garage) end)

    -- Apply 4 layers of invulnerability from towers
    ApplyModifier(hero.garage, "modifier_invulnerability_layer")
    hero.garage:SetModifierStackCount("modifier_invulnerability_layer", GameRules.APPLIER, 4)
    hero.invulnCount = 4

    -- The main hero is an invulnerable fake just used to get global upgrades
    --hero:SetAbsOrigin(center_position)
    FindClearSpaceForUnit(hero, center_position, true)

    -- Upgrade Shop
    local shopEnt = Entities:FindByNameWithin(nil, "*shop_position", center_position, 1000)
    hero.pimpery = CreateUnitByName("peon_pimpery", shopEnt:GetAbsOrigin(), false, hero, hero, teamNumber)
    hero.pimpery:SetOwner(hero)
    hero.pimpery:SetControllableByPlayer(playerID, true)
    hero.pimpery:SetAngles(0, -90, 0)

    PMP:GiveItemUpgrades(hero.pimpery)

	-- Towers - 1 on each corner
    hero.towers = {}
    local towerEnts = Entities:FindAllByNameWithin("*tower_position", center_position, 1200)
    for k,tower in pairs(towerEnts) do
        local tower = CreateUnitByName("peon_tower", tower:GetAbsOrigin(), false, hero, hero, teamNumber)
        tower:SetOwner(hero)
        tower:SetControllableByPlayer(playerID, true)
        table.insert(hero.towers, tower)
    end

	-- Barricades - 3 on each side
    print("[PMP] Setting Up Barricades")
    hero.barricade_positions = {}
    local Barricades = GameRules.Barricades
    local randomN = Barricades["Random"]

    local barricadeEntsX = Entities:FindAllByNameWithin("*barricade_positionX", center_position, 1200)
    for k,v in pairs(barricadeEntsX) do
        local pos = v:GetAbsOrigin()

        for i=-1,1 do
            local nBarricade = tostring(RandomInt(1, randomN))
            local posX = pos+Vector(i*80,0,0)
            local barricade = CreateUnitByName("barricade", posX, false, hero, hero, teamNumber)
            barricade:SetModel(Barricades[nBarricade]["Model"])
            barricade:SetModelScale(Barricades[nBarricade]["Scale"])
            barricade:SetAngles(0, RandomInt(0,360), 0)
            barricade:SetAbsOrigin(GetGroundPosition(posX, barricade))
            barricade:SetOwner(hero)
        end

        table.insert(hero.barricade_positions, pos)
    end

    local barricadeEntsY = Entities:FindAllByNameWithin("*barricade_positionY", center_position, 1200)
    for k,v in pairs(barricadeEntsY) do
        local pos = v:GetAbsOrigin()

        for i=-1,1 do
            local nBarricade = tostring(RandomInt(1, randomN))
            local posY = pos+Vector(0,i*80,0)
            local barricade = CreateUnitByName("barricade", posY, false, hero, hero, teamNumber)
            barricade:SetModel(Barricades[nBarricade]["Model"])
            barricade:SetModelScale(Barricades[nBarricade]["Scale"])
            barricade:SetAngles(0, RandomInt(0,360), 0)
            barricade:SetAbsOrigin(GetGroundPosition(posY, barricade))
        end

        table.insert(hero.barricade_positions, pos)
    end

    -- Tracking
    hero.lumber = 0
    hero.food_used = 0
    hero.food_limit = 0
    hero.spawn_rate = 1

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

    PMP:PrintUpgrades(playerID)

    -- Set Resources
    Timers:CreateTimer(function()
        SetGold(playerID, INITIAL_GOLD)
        SetLumber(playerID, INITIAL_LUMBER)
        SetFoodUsed(playerID, 0)
        SetFoodLimit(playerID, INITIAL_FOOD_LIMIT)

        -- Set initial units
        hero.units = {}
        for i=1,INITIAL_PEONS do
            local unit = CreateUnitByName("peon", center_position, true, hero, hero, hero:GetTeamNumber())
            unit:SetOwner(hero)
            unit:SetControllableByPlayer(playerID, true)
            FindClearSpaceForUnit(unit, center_position, true)
            ModifyFoodUsed(playerID, 1)
            table.insert(hero.units, unit)
        end
    end)
end

ITEM_UPGRADE_LIST = 
{ 
    "item_upgrade_critical_strike1",
    "item_upgrade_stun_hit1",
    "item_upgrade_poisoned_weapons1",
    "item_upgrade_pulverize1",
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

    ApplyModifier(npc, "modifier_attackable")
end

function PMP:OnHeroInGame(hero)
	local hero_name = hero:GetUnitName()
	print("[PMP] OnHeroInGame "..hero_name)

    ClearAbilities(hero)
    TeachAbility(hero, "hide_hero", 1)

    -- Global upgrade abilities
    hero:AddAbility("pimp_damage")
    hero:AddAbility("pimp_armor")
    hero:AddAbility("pimp_speeds")
    hero:AddAbility("pimp_regen")

    hero:AddNoDraw()
end

function PMP:OnGameInProgress()
	print("[PMP] The game has officially begun")
end

-- The overall game state has changed
function PMP:OnGameRulesStateChange(keys)
	local newState = GameRules:State_Get()

	print("[PMP] GameRules State Changed: ",newState)
			
	if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
		self.bSeenWaitForPlayers = true
	elseif newState == DOTA_GAMERULES_STATE_INIT then
		Timers:RemoveTimer("alljointimer")
	elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		local et = 6
		if self.bSeenWaitForPlayers then
			et = .01
		end
		Timers:CreateTimer("alljointimer", {
			useGameTime = true,
			endTime = et,
			callback = function()
			if PlayerResource:HaveAllPlayersJoined() then
				PMP:PostLoadPrecache()
				PMP:OnAllPlayersLoaded()
				return 
			end
			return 1
		end
		})
	elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		PMP:OnGameInProgress()
	end
end

-- An entity died
function PMP:OnEntityKilled( event )
	--print( '[PMP] OnEntityKilled Called' )

	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript(event.entindex_killed)
	-- The Killing entity
	local killerEntity
	if event.entindex_attacker then
		killerEntity = EntIndexToHScript(event.entindex_attacker)
	end

	-- Owner handles of the unit
	local player = killedUnit:GetPlayerOwner()
    if not player then return end

    local playerID = player:GetPlayerID()
    local hero = player:GetAssignedHero()

	-- Hero Killed

	-- Substract the Food Used
    local food = GetFoodCost(killedUnit:GetUnitName())
    ModifyFoodUsed(playerID, -food)

	-- Table cleanup
    local unit_table = GetPlayerUnits(playerID)
    local unit_index = getIndexTable(unit_table, killedUnit)
    if unit_index then
        table.remove(unit_table, unit_index)
    end

	-- Remove prop wearable of a unit
    if killedUnit:IsCreature() then
        Timers:CreateTimer(4, function()
            ClearPropWearables(killedUnit)
        end)
    end
	
	-- Give Experience to heroes based on the level of the killed creature

    if IsCustomTower(killedUnit) then
        local unit_index = getIndexTable(unit_table, killedUnit)

        --GiveBountyToTeam(killerEntity:GetTeamNumber(), killedUnit)
        ReduceInvulnerabilityCount(hero)
    end

end

-- Player changed selection
function PMP:OnPlayerSelectedEntities( event )
	local pID = event.pID

	GameRules.SELECTED_UNITS[pID] = event.selected_entities
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
			if player:GetTeamNumber() == teamID then
				local playerName = PlayerResource:GetPlayerName(playerID)
				if playerName == "" then playerName = "Player "..playerID end
				GameRules:SendCustomMessage(playerName.." was victorious", 0, 0)
			end
		end
	end
end