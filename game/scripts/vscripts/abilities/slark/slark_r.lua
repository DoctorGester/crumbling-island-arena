slark_r = class({})

LinkLuaModifier("modifier_slark_r", "abilities/slark/modifier_slark_r", LUA_MODIFIER_MOTION_NONE)

function slark_r:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:AddNewModifier(hero, self, "modifier_slark_r", { duration = 3 })

    for _, modifier in pairs(hero:AllModifiers()) do
        if modifier:GetName() == "modifier_slark_a" then
            modifier:SetPurged(true)
        end
    end

    hero:GetUnit():Purge(false, true, false, false, false)
    hero:EmitSound("Arena.Slark.CastR")
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(slark_r)