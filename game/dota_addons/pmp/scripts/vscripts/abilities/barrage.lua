function BarrageAttack( event )
    local caster = event.caster
    local ability = event.ability
    local target_entities = event.target_entities

    for k,v in pairs(target_entities) do
        local projTable = {
            EffectName = GetRangedProjectileName(caster),
            Ability = ability,
            Target = v,
            Source = caster,
            bDodgeable = true,
            bProvidesVision = false,
            vSpawnOrigin = caster:GetAbsOrigin(),
            iMoveSpeed = 900,
            iVisionRadius = 0,
            iVisionTeamNumber = caster:GetTeamNumber(),
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
        }
        ProjectileManager:CreateTrackingProjectile(projTable)
    end
end