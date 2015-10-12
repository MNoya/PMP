customSchema = class({})

function customSchema:init(options)
    
    -- Flags
    statCollection:setFlags({version = GetVersion()})

    -- Listen for changes in the current state
    ListenToGameEvent('game_rules_state_change', function(keys)
        -- Grab the current state
        local state = GameRules:State_Get()
    
        if state == DOTA_GAMERULES_STATE_POST_GAME then
    
            -- Build game array
            local game = BuildGameArray()

            -- Build players array
            local players = BuildPlayersArray()

            -- Print the schema data to the console
            if statCollection.TESTING then
                PrintSchema(game,players)
            end

            -- Send custom stats
            if statCollection.HAS_SCHEMA then
                statCollection:sendCustom({game=game, players=players})
            end
        end
    end, nil)
end

function customSchema:submitRound(args)
    winners = BuildRoundWinnerArray()
    game = BuildGameArray()
    players = BuildPlayersArray()

    statCollection:sendCustom({game=game, players=players})
    
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
    game.wr = GetRaceWinner() --Winner Race, in team games it will be the player with the highest kill score from the winning team.
    game.bk = GetBossKilled() --Boss Killed
    game.tt = GetTimesTraded() --Trades
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
                    ph = GetPlayerRace(playerID), --Race
                    pk = PlayerResource:GetKills(playerID), --Kills
                    pd = PlayerResource:GetDeaths(playerID), --Deaths
                    pl = GetHeroLevel(playerID), --Level
                    
                    -- Resources
                    pf = GetFoodLimit(playerID), --Food
                    psr = GetSpawnRate(playerID), --Spawn Rate
                    tge = GetTotalEarnedGold(playerID), --Gold Earned
                    tle = GetTotalEarnedLumber(playerID), --Lumber Earned
                    txe = GetTotalEarnedXP(playerID), --Experience Earned                   

                    -- Defensive abilities
                    spu = GetSuperPeonsUsed(playerID), --Super Peons Used
                    bu = GetBarricadesUsed(playerID), --Barricades Built
                    ru = GetRepairsUsed(playerID), --Repairs Used

                    -- Upgrades
                    uw = GetPlayerWeaponLevel(playerID), --upgrade_weapon
                    uh = player_upgrades["helm"] or 0, --upgrade_helm
                    ua = player_upgrades["armor"] or 0, --upgrade_armor
                    uw = player_upgrades["wings"] or 0, --upgrade_wings
                    uhp = player_upgrades["health"] or 0, --upgrade_health

                    -- Passive ability upgrades
                    acs = player_upgrades["critical_strike"] or 0, --Critical Strike Level
                    ash = player_upgrades["stun_hit"] or 0, --Stun Hit Level
                    apw = player_upgrades["poisoned_weapons"] or 0, --Poisoned Weapon Level
                    ar = player_upgrades["racial"] or 0, --Racial Level
                    ad = player_upgrades["dodge"] or 0, --Dodge Level
                    asa = player_upgrades["spiked_armor"] or 0, --Spiked Armor Level
                    
                    -- Hero global upgrades
                    pdmg = player_upgrades["pimp_damage"] or 0, --Pimp Damage
                    parm = player_upgrades["pimp_armor"] or 0, --Pimp Armor
                    pspd = player_upgrades["pimp_speed"] or 0, --Pimp Speed
                    preg = player_upgrades["pimp_regen"] or 0, --Pimp Regen
                })
            end
        end
    end

    return players
end

function PrintSchema( gameArray, playerArray )
    print("-------- GAME DATA --------")
    DeepPrintTable(gameArray)
    print("\n-------- PLAYER DATA --------")
    DeepPrintTable(playerArray)
    print("-------------------------------------")
end

function GetPlayerWeaponLevel( playerID )
    local player_upgrades = PMP:GetUpgradeList(playerID)
    local race = GetPlayerRace(playerID)
    local weapon_level = 0
    
    if race == "night_elf" then
        weapon_level = player_upgrades["bow"] + player_upgrades["quiver"]
    else
        weapon_level = player_upgrades["weapon"]
    end

    return weapon_level
end