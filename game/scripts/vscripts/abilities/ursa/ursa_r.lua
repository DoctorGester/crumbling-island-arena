ursa_r = class({})

LinkLuaModifier("modifier_ursa_r", "abilities/ursa/modifier_ursa_r", LUA_MODIFIER_MOTION_NONE)

function ursa_r:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:GetUnit():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
    hero:AddNewModifier(hero, self, "modifier_ursa_r", { duration = 1.8 })
    hero:EmitSound("Arena.Ursa.CastR")

    local fury = hero:FindModifier("modifier_ursa_fury")
    local frenzy = hero:FindModifier("modifier_ursa_frenzy")

    if fury then
        fury:IncreaseStacks(10)
    elseif frenzy then
        frenzy:SetDuration(6, true)
    end

    ScreenShake(hero:GetPos(), 5, 150, 0.45, 3000, 0, true)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(ursa_r)