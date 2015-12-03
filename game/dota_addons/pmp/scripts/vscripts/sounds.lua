--[[    Custom Sound Set playing
Events
    * Spawn (Ready to work!)
    * Select (What?)
    * Move (Work, work)
    * Attack (I'll try!)
    * Attack rare (Warcry)
    * Select rare (Pissed) 
--]]

if not Sounds then
  Sounds = class({})
  CustomGameEventManager:RegisterListener( "play_selected_sound", Dynamic_Wrap(Sounds, "PlaySelectedSound"))
end

function Sounds:Start()
    Sounds.Sets = LoadKeyValues("scripts/kv/sounds.kv")
    Sounds.LastSoundDuration = {}
    Sounds.LastAnnouncerTime = {}
    Sounds.SoundPlayTime = {}
    Sounds.PissedUnits = {}

    Sounds.OrdersToStrings = {
        [DOTA_UNIT_ORDER_MOVE_TO_POSITION]="move",
        [DOTA_UNIT_ORDER_MOVE_TO_TARGET]="move",
        [DOTA_UNIT_ORDER_ATTACK_MOVE]="attack",
        [DOTA_UNIT_ORDER_ATTACK_TARGET]="attack",
        ["SELECT"] = "select",
        ["SPAWN"] = "spawn",
        ["DIE"] = "die",
        ["PISSED"] = "pissed",
    }

    print("[sounds.lua] Start")
end

function Sounds:PlaySoundSet( playerID, unit, order )
    if not IsValidEntity(unit) then return end
    local player = PlayerResource:GetPlayer(playerID)
    local gameTime = GameRules:GetGameTime()
    local name = unit:GetUnitName()
    local soundSet = Sounds.Sets[name]
    local order_translation = Sounds.OrdersToStrings[order]
    local order_line = soundSet and soundSet[order_translation]

    -- We got a line for the specific order
    if order_line then
        
        -- Find the table associated with this order on our sounds keyvalue table
        local sound_table = Sounds:GetRandomLineForOrder(order_line)
        if not sound_table then return end
        local sound_string = sound_table['String']   
        local randomThresholdTime = RandomInt(1,2)
        local duration = sound_table['Duration'] + randomThresholdTime
        local sound_type = sound_table['Type'] --Area sounds      

        -- Pissed orders can be send more frequently if we're spamming click on units
        if order == "PISSED" then
            duration = sound_table['Duration']
        end

        if order == "DIE" then
            EmitSoundOn(sound_string, unit)
        end

        -- Prevents overlapping
        if not Sounds:IsStillPlaying(playerID) then  

            if order == "SPAWN" then
                EmitSoundOnLocationForAllies(unit:GetAbsOrigin(), sound_string, unit)
            else
                Sounds:EmitSoundOnClient( playerID, sound_string )
            end

            --print("Playing",sound_string,"for",duration,"seconds")
            Sounds:SetNextValidTime(playerID, gameTime + duration)
        end
    end
end

function Sounds:PlaySelectedSound( event )
    local playerID = event.pID
    local entityIndex = event.unit_index
    local unit = EntIndexToHScript(entityIndex)
    local bIsPissed = tobool(event.pissed)

    if bIsPissed then
        Sounds:PlaySoundSet( playerID, unit, "PISSED" )
    else
        Sounds:PlaySoundSet( playerID, unit, "SELECT" )
    end
end

function Sounds:GetRandomLineForOrder( soundset_table )
    local random = 'Default'
    local sound_table = soundset_table[random]
    local chance_table = soundset_table['Chance']
    
    -- Roll chances
    if chance_table then
        for k,value in pairs(chance_table) do
            if RollPercentage(value) then
                random = k
            end
        end
    end

    return soundset_table[random]
end

function Sounds:GetUpgradeSound( upgrade_name )
    local upgrade_table = Sounds.Sets['announcer']['upgrades']
    return upgrade_table[upgrade_name]
end

function Sounds:IsStillPlaying( playerID )
    local current_time = GameRules:GetGameTime()
    local valid_time = Sounds:GetNextValidTime(playerID)
    return current_time <= valid_time
end

function Sounds:GetNextValidTime( playerID )
    return Sounds.LastSoundDuration[playerID] or 0
end

function Sounds:SetNextValidTime( playerID, time )
    Sounds.LastSoundDuration[playerID] = time
end

function Sounds:TimeSinceLastAnnounce(playerID)
    return GameRules:GetGameTime() - (Sounds.LastAnnouncerTime[playerID] or 0)
end

function Sounds:EmitSoundOnClient( playerID, sound )
    local player = PlayerResource:GetPlayer(playerID)

    -- Don't play sounds during tutorial
    if Tutorial.Active[playerID] then return end

    if player then
        if string.match("Announcer.", sound) and Sounds:TimeSinceLastAnnounce(playerID) >= 2 then
            Sounds.LastAnnouncerTime[playerID] = GameRules:GetGameTime()
            CustomGameEventManager:Send_ServerToPlayer(player, "emit_client_sound", {sound=sound})
        else
            CustomGameEventManager:Send_ServerToPlayer(player, "emit_client_sound", {sound=sound})
            return true
        end
    else
        print("ERROR - No player with ID",playerID)
    end
    return false
end

function Sounds:PlayUpgradeSound(playerID, upgrade_name)
    local sound_string = Sounds:GetUpgradeSound( upgrade_name )
    Sounds:EmitSoundOnClient( playerID, sound_string )
end

function Sounds:PlayUpgradeSoundMax(playerID, upgrade_name)
    local sound_string = Sounds:GetUpgradeSound( upgrade_name )..'.Max'
    Sounds:EmitSoundOnClient( playerID, sound_string )
end

function Sounds:ResolveAttackedSounds(victim)
    local playerID = victim:GetPlayerOwnerID()

    if Tutorial.Active[playerID] then return end

    if IsCustomBuilding(victim) then
        -- Choose a possible line for each structure
        local sound = "Announcer.Attacked.Structures"

        if victim:GetHealthPercent() <= 25 then
            sound = "Announcer.Attacked.Structures.Heavy"
        end

        -- Specific structure line
        if RollPercentage(50) then
            if IsCityCenter(victim) then
                sound = "Announcer.Attacked.Garage"
            elseif IsOutpost(victim) then
                sound = "Announcer.Attacked.Outpost"
            elseif IsCustomTower(victim) then
                sound = "Announcer.Attacked.Tower"
            end
        end

        -- Restrict any 'under attack' every some seconds
        if Sounds:TimeSinceLastPlayed(playerID, "ATTACKED") > 15 then
            -- Play the sound, if it can't be played then don't increase the countdown
            if Sounds:EmitSoundOnClient(playerID, sound) then
                Sounds:SetTimePlayed(playerID, "ATTACKED")
            end
        end

        -- Announce other allies that the player is under attack
        local teamNumber = victim:GetTeamNumber()
        for i=0,DOTA_MAX_TEAM_PLAYERS do
            if i~=playerID and PlayerResource:IsValidPlayerID(i) and PlayerResource:GetTeam(i) == teamNumber then
                if Sounds:TimeSinceLastPlayed(i, "ALLIED_ATTACKED") > 30 then
                    if Sounds:EmitSoundOnClient(i, "Announcer.Attacked.Ally") then
                        Sounds:SetTimePlayed(i, "ALLIED_ATTACKED")
                    end
                end
            end
        end

    elseif IsPimpUnit(victim) then

        if Sounds:TimeSinceLastPlayed(playerID, "Announcer.Attacked.Army") > 30 then
            if Sounds:EmitSoundOnClient(playerID, "Announcer.Attacked.Army") then
                Sounds:SetTimePlayed(playerID, "Announcer.Attacked.Army")
            end
        end
    end
end

function Sounds:TimeSinceLastPlayed(playerID, sound)
    return GameRules:GetGameTime() - Sounds:GetTimePlayed(playerID, sound)
end

function Sounds:SetTimePlayed(playerID, sound)
    Sounds.SoundPlayTime[playerID][sound] = GameRules:GetGameTime()
end

function Sounds:GetTimePlayed(playerID, sound)
    Sounds.SoundPlayTime[playerID] = Sounds.SoundPlayTime[playerID] or {}
    return (Sounds.SoundPlayTime[playerID] and Sounds.SoundPlayTime[playerID][sound]) or 0
end

Sounds:Start()

---------------------------------------------------------

function PlayAnnouncerSound( event )
    local playerID = event.caster:GetPlayerOwnerID()
    local sound = tostring(event.Sound)

    Sounds:EmitSoundOnClient( playerID, sound )
end