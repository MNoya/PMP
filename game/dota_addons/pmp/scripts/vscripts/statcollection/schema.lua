--[[
Usage:

This is an example custom schema. You must assemble your game and players tables, which
are submitted to the library via a call like:

statCollection:sendCustom(schemaAuthKey, game, players)

The schemaAuthKey is important, and can only be obtained via site admins.

Come bug us in our IRC channel or get in contact via the site chatbox. http://getdotastats.com/#contact

]]
local customSchema = class({})
function customSchema:init(options)
    
    -- Set settings
    self.SCHEMA_KEY = statInfo.schemaID
    self.HAS_ROUNDS = tobool(statInfo.HasRounds)
    self.GAME_WINNER = tobool(statInfo.GameWinner)
    self.ANCIENT_EXPLOSION = tobool(statInfo.AncientExplosion)
    self.statCollection = options.statCollection

    -- Listen for changes in the current state
    ListenToGameEvent('game_rules_state_change', function(keys)
        -- Grab the current state
        local state = GameRules:State_Get()
    
        if state == DOTA_GAMERULES_STATE_POST_GAME then
    
            -- Build game array
            local game = {}
            table.insert(game, {
                boss_killed = GetBossKilled(),
                times_traded = GetTimesTraded()
            })
    
            -- Build players array
            local players = {}
            for playerID = 0, DOTA_MAX_PLAYERS do
                if PlayerResource:IsValidPlayerID(playerID) then
                    if not PlayerResource:IsBroadcaster(playerID) then
                        local player_upgrades = PMP:GetUpgradeList(playerID)
                        table.insert(players, {
                            --steamID32 required in here
                            steamID32 = PlayerResource:GetSteamAccountID(playerID),
                            player_hero_id = PlayerResource:GetSelectedHeroID(playerID),
                            player_kills = PlayerResource:GetKills(playerID),
                            player_deaths = PlayerResource:GetDeaths(playerID),
                            player_level = PlayerResource:GetSelectedHeroEntity(playerID):GetLevel(),
                            
                            -- Resources
                            --player_gold = GetGold(playerID),
                            --player_lumber = GetLumber(playerID),
                            player_food = GetFoodLimit(playerID),
                            player_spawn_rate = GetSpawnRate(playerID),

                            -- Upgrades
                            upgrade_weapon = player_upgrades["weapon"],
                            upgrade_helm = player_upgrades["helm"],
                            upgrade_armor = player_upgrades["armor"],
                            upgrade_wings = player_upgrades["wings"],
                            upgrade_health = player_upgrades["health"],

                            -- Passive ability upgrades
                            ability_critical_strike = player_upgrades["critical_strike"],
                            ability_stun_hit = player_upgrades["stun_hit"],
                            ability_poisoned_weapons = player_upgrades["poisoned_weapons"],
                            ability_pulverize = player_upgrades["pulverize"],
                            ability_dodge = player_upgrades["dodge"],
                            ability_spiked_armor = player_upgrades["spiked_armor"],
                            
                            -- Hero global upgrades
                            pimp_damage = player_upgrades["pimp_damage"],
                            pimp_armor = player_upgrades["pimp_armor"],
                            pimp_speed = player_upgrades["pimp_speed"],
                            pimp_regen = player_upgrades["pimp_regen"],
                        })
                    end
                end
            end
    
            -- Send custom stats
            self.statCollection:sendCustom({game=game, players=players})
        end
    end, nil)
end
function customSchema:submitRound(args)
end
return customSchema