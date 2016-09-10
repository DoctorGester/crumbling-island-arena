pl_r = class({})
local self = pl_r

function self:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local direction = self:GetDirection()
    EntityPLIllusion(hero.round, hero, hero:GetPos() - direction * 180, self:GetDirection(), self):Activate():QueueCast(hero:GetPos())
end

function self:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end
