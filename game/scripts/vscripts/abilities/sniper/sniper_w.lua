sniper_w = class({})
LinkLuaModifier("modifier_sniper_w", "abilities/sniper/modifier_sniper_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sniper_w_trap", "abilities/sniper/modifier_sniper_w_trap", LUA_MODIFIER_MOTION_NONE)

require("abilities/sniper/entity_sniper_w")

function sniper_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    ArcProjectile(self.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target,
        speed = 2300,
        arc = 600,
        graphics = "particles/sniper_w/sniper_w.vpcf",
        hitScreenShake = true,
        hitFunction = function(projectile, hit)
            EntitySniperW(hero.round, hero, target, self):Activate()
        end
    }):Activate()
end

function sniper_w:GetCastAnimation()
    return ACT_DOTA_TELEPORT_END
end