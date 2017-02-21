dusa_e = class({})
local self = dusa_e

LinkLuaModifier("modifier_dusa_e", "abilities/dusa/modifier_dusa_e", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:EmitSound("Arena.Medusa.CastE")
    hero:AddNewModifier(hero, self, "modifier_dusa_e", { duration = 3 })

    local lastCast = self.lastCast or 0
    local now = Time()

    if now - lastCast > 1.5 then
        hero:EmitSound("Arena.Medusa.CastE.Voice")
        self.lastCast = now
    end
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(dusa_e)