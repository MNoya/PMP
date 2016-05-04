if not AI then
    AI = class({})
end

function AI:Init()
    AI.Players = {}
end

local races = {"npc_dota_hero_axe","npc_dota_hero_undying","npc_dota_hero_skeleton_king","npc_dota_hero_meepo","npc_dota_hero_dragon_knight",
               "npc_dota_hero_drow_ranger","npc_dota_hero_silencer","npc_dota_hero_treant","npc_dota_hero_warlock"}

function AI:SpawnBots()
    local player_count = PlayerResource:GetPlayerCount()
    local bots_required = PMP_MAX_PLAYERS - player_count

    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, bots_required + PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS) )
    for i=player_count,PMP_MAX_PLAYERS do
        Timers:CreateTimer(i*0.1, function()
            Tutorial:AddBot('npc_dota_hero_axe','','',false) --This will actually pick random heroes because of reasons
        end)
    end

    local first_free_team = player_count
    Timers:CreateTimer(1, function()
        for playerID = 1, PMP_MAX_PLAYERS-1 do
            if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:IsFakeClient(playerID) then
                if PlayerResource:HasSelectedHero(playerID) then
                    AI:InitFakePlayer(playerID)
                else
                    local player = PlayerResource:GetPlayer(playerID)
                    if player and not PlayerResource:HasSelectedHero(playerID) then
                        CreateHeroForPlayer(races[RandomInt(1,#races)], player)
                        AI:InitFakePlayer(playerID)
                    end
                end
            end
        end
        GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 1 )
    end)
end

function AI:InitFakePlayer(playerID)
    for k,teamID in pairs(VALID_TEAMS) do
        if PlayerResource:GetPlayerCountForTeam(teamID) == 0 then
            PlayerResource:SetCustomTeamAssignment(playerID, teamID)
            break
        end
    end

    Timers:CreateTimer(0.1, function()
        print("InitFakePlayer", playerID, PlayerResource:HasSelectedHero(playerID), PlayerResource:GetSelectedHeroEntity(playerID))
    end)

    -- start thinking what to use resources on
    -- start grouping units and form an attack strategy
end

if not AI.Players then AI:Init() end