function Spawn( trigger )
    local activator = trigger.activator

    if activator and activator:GetUnitName() ~= "trader" and not GameRules.Boss then
        local spawnEnt = Entities:FindByName(nil, "boss_spawn_point")
        local position = spawnEnt:GetAbsOrigin()
        local boss = CreateUnitByName("nian_boss", position, true, nil, nil, DOTA_TEAM_NEUTRALS)
        
        boss:StartGesture(ACT_DOTA_AREA_DENY)
        boss:SetAngles(0,45,0)

        GameRules.Boss = boss
        print("[PMP] Boss Active")
    end
end