earth_spirit_a = class({})

LinkLuaModifier("modifier_earth_spirit_a", "abilities/earth_spirit/modifier_earth_spirit_a", LUA_MODIFIER_MOTION_NONE)

function earth_spirit_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:EmitSound("Arena.Sven.CastA")

    return true
end

function earth_spirit_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster():GetParentEntity()
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local range = hero:HasModifier("modifier_earth_spirit_stand") and 400 or 300
    local damage = self:GetDamage()
    local nonStandFilter = Filters.WrapFilter(function(target) return hero:GetRemnantStand() ~= target end)

    hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, range, forward, math.pi) + nonStandFilter,
        sound = "Arena.Earth.HitA",
        damage = self:GetDamage(),
        modifier = { name = "modifier_earth_spirit_a", duration = 1.5, ability = self },
        knockback = { force = 20, decrease = 3 },
        isPhysical = true
    })
end

function earth_spirit_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function earth_spirit_a:GetPlaybackRateOverride()
    return 3
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(earth_spirit_a)