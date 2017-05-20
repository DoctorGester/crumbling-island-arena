undying_w = class({})

LinkLuaModifier("modifier_undying_w", "abilities/undying/modifier_undying_w", LUA_MODIFIER_MOTION_NONE)

function undying_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local projectile = DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos(),
        to = target ,
        speed = 700,
        distance = 1500,
        radius = 100,
        graphics = "particles/undying_w/undying_w.vpcf",
        continueOnHit = true,
        ignoreProjectiles = true,
        considersGround = true,
        damage = self:GetDamage(),
        hitModifier = { name = "modifier_undying_w", duration = 1.5, ability = self }
    }):Activate()

    projectile.Update = function(self)
        DistanceCappedProjectile.Update(self)

        self.soundTick = (self.soundTick or 0) + 1

        if self.soundTick % 8 == 0 and self.distancePassed <= self.distance * 0.8 then
            self:EmitSound("Arena.Undying.LoopW")
        end
    end
end

function undying_w:GetCastAnimation()
    return ACT_DOTA_UNDYING_SOUL_RIP
end

function undying_w:GetPlaybackRateOverride()
    return 1.66
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(undying_w)