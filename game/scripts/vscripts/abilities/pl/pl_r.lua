pl_r = class({})
local self = pl_r

function self:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local direction = self:GetDirection()
    EntityPLIllusion(hero.round, hero, hero:GetPos() - direction * 180, self:GetDirection(), self):Activate():QueueCast(hero:GetPos())

end

--function self:GetCastAnimation()
--    return ACT_DOTA_CAST_ABILITY_1
--end

--function self:GetPlaybackRateOverride()
--    return 4.0
--end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(pl_r)