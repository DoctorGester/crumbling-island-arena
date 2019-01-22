timber_r_sub = class({})

LinkLuaModifier("modifier_timber_r", "abilities/timber/modifier_timber_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_timber_r_aura", "abilities/timber/modifier_timber_r_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_timber_r_target", "abilities/timber/modifier_timber_r_target", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_timber_r_slow", "abilities/timber/modifier_timber_r_slow", LUA_MODIFIER_MOTION_NONE)

require("abilities/timber/entity_timber_r")

function timber_r_sub:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1200)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    ArcProjectile(self.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos(),
        to = target,
        speed = 2400,
        arc = 600,
        graphics = "particles/timber_r/timber_r.vpcf",
        hitFunction = function(projectile, hit)
            EntityTimberR(hero.round, hero, target, self):Activate()
        end
    }):Activate()

    hero:SwapAbilities("timber_r_sub", "timber_r")
    hero:FindAbility("timber_r_sub"):StartCooldown(hero:FindAbility("timber_r_sub"):GetCooldown(1))

    CreateEntityAOEMarker(target, 400, (target - hero:GetPos()):Length2D() / 2400 + 0.1, { 255, 106, 0 }, 0.3, true)


    hero:EmitSound("Arena.Timber.CastR")

end

function timber_r_sub:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function timber_r_sub:GetPlaybackRateOverride()
    return 1.33
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(timber_r_sub)