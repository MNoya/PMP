-- Gives vision over an area and shows a particle to the team
function FarSight( event )
    local caster = event.caster
    local team = caster:GetTeam()
    local ability = event.ability
    local level = ability:GetLevel()
    local reveal_radius = ability:GetLevelSpecialValueFor( "reveal_radius", level - 1 )
    local duration = ability:GetLevelSpecialValueFor( "duration", level - 1 )

    local allHeroes = HeroList:GetAllHeroes()
    local particleName = "particles/items_fx/dust_of_appearance.vpcf"
    local target = event.target_points[1]

    EmitSoundOnLocationForAllies(target, "DOTA_Item.DustOfAppearance.Activate", caster)

    -- Particle for team
    local particle = ParticleManager:CreateParticleForTeam(particleName, PATTACH_WORLDORIGIN, caster, team)
    ParticleManager:SetParticleControl( particle, 0, target )
    ParticleManager:SetParticleControl( particle, 1, Vector(reveal_radius,1,reveal_radius) )
    
    -- Vision
    AddFOWViewer(team, target, reveal_radius, duration, false)
end