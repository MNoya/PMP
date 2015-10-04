function CheckTarget(event)
    local caster = event.caster
    local target = event.target
    local ability = event.ability

    if target:HasAbility("skeleton_racial") then
        ability:ApplyDataDrivenModifier(caster, target, "modifier_reincarnation_buff", {})
    end
end

function ReincarnationCheck( event )
    local caster = event.caster
    local ability = event.ability
    local damage = event.Damage

    -- Check if the damage would be lethal
    local health = caster:GetHealth()
    if (health - damage) <= 0 then

        local chance = ability:GetLevelSpecialValueFor("reincarnate_chance", ability:GetLevel()-1)

        -- Double the chance under the effects of the leaders aura
        if caster:HasModifier("modifier_reincarnation_buff") then
            chance = chance * 2
        end

        if RollPercentage(chance) then
            caster:SetHealth(1)

            local duration = 2
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_reincarnating", {duration=duration})

            local particleName = "particles/custom/skeleton/reincarnate_explode.vpcf"
            ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)

            StartAnimation(caster, {duration=duration, activity=ACT_DOTA_DIE_SPECIAL, rate=1.5})
            Timers:CreateTimer(duration, function()
                local particleName = "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf"
                ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
                caster:RespawnUnit()
            end)
        end
    end
end