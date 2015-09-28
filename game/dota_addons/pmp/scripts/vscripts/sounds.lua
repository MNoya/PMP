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
end

function Sounds:Start()
    Sounds.Sets = LoadKeyValues("scripts/kv/sounds.kv")
    Sounds.LastSoundDuration = {}

    Sounds.OrdersToStrings = {
        [DOTA_UNIT_ORDER_MOVE_TO_POSITION]="move",
        [DOTA_UNIT_ORDER_MOVE_TO_TARGET]="move",
        [DOTA_UNIT_ORDER_ATTACK_MOVE]="attack",
        [DOTA_UNIT_ORDER_ATTACK_TARGET]="attack",
        ["SELECT"] = "select",
        ["SPAWN"] = "spawn",
        ["DIE"] = "die",
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
        
        if order == "DIE" then
            local sound_table = Sounds:GetRandomLineForOrder(order_line)
            local sound_string = sound_table['String']
            unit:EmitSound(sound_string)
        end

        -- Prevents overlapping     
        if not Sounds:IsStillPlaying(playerID) then
            -- Find the table associated with this order on our sounds keyvalue table
            local sound_table = Sounds:GetRandomLineForOrder(order_line)
            
            local sound_string = sound_table['String']            
            local duration = sound_table['Duration']

            EmitSoundOnClient(sound_string, player)
            Sounds:SetNextValidTime(playerID, gameTime + duration)
        end
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

Sounds:Start()