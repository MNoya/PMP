function StartCooldown( event )
    local ability = event.ability
    ability:StartCooldown(ability:GetCooldown(1))
end

function HideAbility( event )
    local ability = event.ability
    ability:SetHidden(true)
end