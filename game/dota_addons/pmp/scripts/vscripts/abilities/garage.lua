function RepairBuildings( event )
    local caster = event.caster -- Garage
    local ability = event.ability
    local repair_percent = ability:GetSpecialValueFor("repair_percent") * 0.01
    RegainHealthPercent(caster, repair_percent)

    local hero = caster:GetOwner()
    if hero then
        local towers = hero.towers
        for k,tower in pairs(towers) do
            if IsValidAlive(tower) then
                RegainHealthPercent(tower, repair_percent)
            end
        end

        local shop = hero.shop
        if IsValidAlive(shop) then
            RegainHealthPercent(shop, repair_percent)
        end
    end
end

function RegainHealthPercent( unit, percentage )
    if unit:GetHealthDeficit() > 0 then
        local health_gain = math.min(unit:GetMaxHealth() * percentage, unit:GetHealthDeficit())
        unit:Heal(health_gain, unit)
        PopupHealing(unit, health_gain)
    end
end


-- Go to each barricade map point and place an extra random crate model on top
function BuildBarricades( event )
    print("Build Barricades")

    local Barricades = GameRules.Barricades

    local caster = event.caster
    local hero = caster:GetOwner()
    local teamNumber = caster:GetTeamNumber()

    local randomN = Barricades["Random"]
    for k,position in pairs(hero.barricade_positions) do
        local nBarricade = tostring(RandomInt(1, randomN))
        local randPos = position+RandomVector(RandomInt(-80,80))
        local barricade = CreateUnitByName("barricade", randPos, false, hero, hero, teamNumber)
        barricade:SetModel(Barricades[nBarricade]["Model"])
        barricade:SetModelScale(Barricades[nBarricade]["Scale"])
        barricade:SetAngles(0, RandomInt(0,360), 0)
        barricade:SetAbsOrigin(GetGroundPosition(randPos, barricade))
        barricade:SetOwner(hero)
    end
end

-- Barricades take 2 hits to destroy
function BarricadeHit( event )
    local caster = event.caster
    
    if not caster.hit then
        caster.hit = 1
        caster:SetHealth(1)
    else
        caster:ForceKill(true)
    end
end

-- Do stuff when a super peon leaves base
function LeaveBase( trigger )
    local activator = trigger.activator
    if IsSuperPeon(activator) and IsValidAlive(activator) then
        print("Super Peon leaving the base")     
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody_low.vpcf", PATTACH_CUSTOMORIGIN, activator)
        ParticleManager:SetParticleControl(particle, 0, activator:GetAbsOrigin())
        activator:ForceKill(true)
        activator:AddNoDraw()
    end
end