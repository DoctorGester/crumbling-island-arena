pl_e = class({})
local self = pl_e

LinkLuaModifier("modifier_pl_illusion", "abilities/pl/modifier_pl_illusion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pl_e_dash", "abilities/pl/modifier_pl_e_dash", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pl_e_slow", "abilities/pl/modifier_pl_e_slow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pl_e_speed", "abilities/pl/modifier_pl_e_speed", LUA_MODIFIER_MOTION_NONE)

require('abilities/pl/entity_pl_illusion')

function self:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1200, 600)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local realTarget = self.BaseClass.GetCursorPosition(self)

    local spells = hero.round.spells

    local illu = spells:FindClosest(realTarget, 300,
        spells:FilterEntities(function(ent)
            return instanceof(ent, EntityPLIllusion)
        end, spells:GetValidTargets())
    )

    if illu then
        illu:SetTarget(hero)
        illu:Refresh()
    else
        EntityPLIllusion(hero.round, hero, target, -self:GetDirection(), self):Activate():SetTarget(hero)
    end
end

function self:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function self:GetPlaybackRateOverride()
    return 2
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(pl_e)