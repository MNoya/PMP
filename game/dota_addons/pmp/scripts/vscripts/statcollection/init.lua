statCollection = require('statcollection/lib/statcollection')
statInfo = LoadKeyValues('scripts/vscripts/statcollection/settings.kv')

ListenToGameEvent('game_rules_state_change', function(keys)
    local state = GameRules:State_Get()
    
    if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then

        -- Init stat collection
        statCollection:init({
            modIdentifier = statInfo.modID, 
            customSchema = statInfo.customSchema
        })
    end
end, nil)