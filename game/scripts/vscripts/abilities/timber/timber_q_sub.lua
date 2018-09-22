timber_q_sub = class({})

function timber_q_sub:OnSpellStart()
    local hero = self:GetCaster().hero

    local chakram = hero:FindAbility("timber_q"):GetChakram()
    chakram:Retract()
    hero:SwapAbilities("timber_q_sub", "timber_q")
    hero:FindAbility("timber_q"):StartCooldown(3.5)
    if hero:HasModifier("modifier_timber_q_recast") then
        hero:RemoveModifier("modifier_timber_q_recast")
    end
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(timber_q_sub)