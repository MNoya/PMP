function AI:InitPlayerLog(playerID)
    self.Logs[playerID] = {}
    self.Logs[playerID].Upgrades = {}
    self.Logs[playerID].LogFilePath = "../../dota_addons/pmp/scripts/vscripts/ai/logs/player"..playerID..".txt"
    if IsInToolsMode() then
        self.Logs[playerID].LogFile = io.open(self.Logs[playerID].LogFilePath, 'w')
    end
end

function AI:Log(playerID, str)
    if self.Logs[playerID].LogFile then
        local gameTime = AI:FormatGameTime()
        self.Logs[playerID].LogFile:write("["..gameTime.."] "..str .."\n")
        self.Logs[playerID].LogFile:flush() 
    end
end

function AI:DebugUpgrades(c, playerID)
    if not playerID then
        --show all bots
    end

    if self.Logs[playerID] then
        local upgrades = self.Logs[playerID].Upgrades 
        for k,v in pairs(upgrades) do
            print(k,v)
        end
    end
end

function AI:FormatGameTime()
    local gameTime  = math.floor(GameRules:GetDOTATime(false, true))
    local time = ""
    local nMins = string.format("%02.f", math.floor(math.abs(gameTime)/60))
    local nSecs = string.format("%02.f", math.floor(math.abs(gameTime)%60))
    if gameTime < 0 then
        time = "-"..time
    end
    return time..nMins..":"..nSecs
end

function AI:ActiveLog( level )
    return AI.PrintLevels[level]
end