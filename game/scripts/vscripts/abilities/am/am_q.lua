am_q = class({})
local self = am_q

require("abilities/am/projectile_am_q")

LinkLuaModifier("modifier_am_damage", "abilities/am/modifier_am_damage", LUA_MODIFIER_MOTION_NONE)

function self:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("Arena.AM.PreQ")

    return true
end
function self:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1500, 500)

    local hero = self:GetCaster():GetParentEntity()
    local target = self:GetCursorPosition()

    hero:EmitSound("Arena.AM.CastQ")

    local firstBlade = ProjectileAMQ(hero.round, hero, target, self, hero:GetMappedParticle("particles/am_q/am_q.vpcf"), "weapon", -1):Activate()
    local secondBlade = ProjectileAMQ(hero.round, hero, target, self, hero:GetMappedParticle("particles/am_q/am_q2.vpcf"), "offhand_weapon", 1):Activate()

    firstBlade:SetSecondBlade(secondBlade)
    secondBlade:SetSecondBlade(firstBlade)

    hero:FindAbility("am_a"):SetActivated(false)
    hero:FindAbility("am_e"):SetActivated(false)
    hero:FindAbility("am_r"):SetActivated(false)
end

function self:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
    -- return ACT_DOTA_CAST_ABILITY_1
end

function self:GetPlaybackRateOverride()
    return 1
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(am_q)