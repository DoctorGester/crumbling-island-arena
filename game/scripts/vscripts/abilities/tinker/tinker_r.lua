tinker_r = class({})

LinkLuaModifier("modifier_tinker_r", "abilities/tinker/modifier_tinker_r", LUA_MODIFIER_MOTION_NONE)

require("abilities/tinker/entity_tinker_r")

function tinker_r:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:EmitSound("Arena.Tinker.CastR.Voice")
    EntityTinkerR(hero.round, hero, target, self):Activate()
    ScreenShake(target, 5, 150, 0.25, 3000, 0, true)
end

function tinker_r:GetCastAnimation()
    return ACT_DOTA_TINKER_REARM3
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(tinker_r)