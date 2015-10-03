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
    self.HAS_ROUNDS = true
    self.GAME_WINNER = true
    self.ANCIENT_EXPLOSION = false
    self.statCollection = options.statCollection

    -- Version flag
    statCollection:setFlags({team_setting = GameRules.PlayersPerTeam, version = GetVersion()})

    -- Listen for changes in the current state
    ListenToGameEvent('game_rules_state_change', function(keys)
        -- Grab the current state
        local state = GameRules:State_Get()
    
        if state == DOTA_GAMERULES_STATE_POST_GAME then
    
            -- Build game array
            local game = BuildGameArray()

            -- Build players array
            local players = BuildPlayersArray()

            -- Send custom stats
            self.statCollection:sendCustom({game=game, players=players})
        end
    end, nil)
end

function customSchema:submitRound(args)
    winners = BuildRoundWinnerArray()
    game = BuildGameArray()
    players = BuildPlayersArray()

    self.statCollection:sendCustom({game=game, players=players})
    
    return {winners = winners, lastRound = false}
end

-------------------------------------

function BuildRoundWinnerArray()
    local winners = {}
    local current_winner_team = GameRules.Winner or 0
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                winners[PlayerResource:GetSteamAccountID(playerID)] = (PlayerResource:GetTeam(playerID) == current_winner_team) and 1 or 0
            end
        end
    end
    return winners
end

function BuildGameArray()
    local game = {}
    game.bk = GetBossKilled() --boss_killed
    game.tt = GetTimesTraded() --times_traded
    return game
end

function BuildPlayersArray()
    players = {}
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                local player_upgrades = PMP:GetUpgradeList(playerID)
                table.insert(players, {
                    --steamID32 required in here
                    steamID32 = PlayerResource:GetSteamAccountID(playerID),
                    phi = PlayerResource:GetSelectedHeroID(playerID), --player_hero_id
                    pk = PlayerResource:GetKills(playerID), --player_kills
                    pd = PlayerResource:GetDeaths(playerID), --player_deaths
                    pl = GetHeroLevel(playerID), --player_level
                    
                    -- Resources
                    tge = GetTotalEarnedGold(playerID), --total_gold_earned
                    tle = GetTotalEarnedLumber(playerID), --total_lumber_earned
                    txe = GetTotalEarnedXP(playerID), --total_xp_earned
                    pf = GetFoodLimit(playerID), --player_food
                    psr = GetSpawnRate(playerID), --player_spawn_rate

                    -- Defensive abilities
                    spu = GetSuperPeonsUsed(playerID), --super_peons_used
                    bu = GetBarricadesUsed(playerID), --barricades_used
                    ru = GetRepairsUsed(playerID), --repairs_used

                    -- Upgrades
                    uw = player_upgrades["weapon"] or 0, --upgrade_weapon
                    uh = player_upgrades["helm"] or 0, --upgrade_helm
                    ua = player_upgrades["armor"] or 0, --upgrade_armor
                    uw = player_upgrades["wings"] or 0, --upgrade_wings
                    uhp = player_upgrades["health"] or 0, --upgrade_health

                    -- Passive ability upgrades
                    acs = player_upgrades["critical_strike"] or 0, --ability_critical_strike
                    ash = player_upgrades["stun_hit"] or 0, --ability_stun_hit
                    apw = player_upgrades["poisoned_weapons"] or 0, --ability_poisoned_weapons
                    ar = player_upgrades["racial"] or 0, --ability_racial
                    ad = player_upgrades["dodge"] or 0, --ability_dodge
                    asa = player_upgrades["spiked_armor"] or 0, --ability_spiked_armor
                    
                    -- Hero global upgrades
                    pdmg = player_upgrades["pimp_damage"] or 0, --pimp_damage
                    parm = player_upgrades["pimp_armor"] or 0, --pimp_armor
                    pspd = player_upgrades["pimp_speed"] or 0, --pimp_speed
                    preg = player_upgrades["pimp_regen"] or 0, --pimp_regen
                })
            end
        end
    end

    return players
end

-------------------------------------

return customSchema