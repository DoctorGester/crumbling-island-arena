modifier_ta_e = class({})

function modifier_ta_e:OnDamageDealt(target, hero, amount)
    local ability = self:GetAbility()
    if not ability:IsCooldownReady() then
        local remaining = ability:GetCooldownTimeRemaining()
        ability:EndCooldown()

        if remaining > amount then
            ability:StartCooldown(remaining - amount)
        end
    end
end

function modifier_ta_e:IsHidden()
    return true
end