phoenix_w = class({})

LinkLuaModifier("modifier_phoenix_w", "abilities/phoenix/modifier_phoenix_w", LUA_MODIFIER_MOTION_NONE)

if IsClient() then
    require('heroes/hero_util')
end

function phoenix_w:OnAbilityPhaseStart()
    return not self:GetCaster():HasModifier(PhoenixUtil.EGG_MODIFIER)
end

PhoenixUtil.CastFitersLocation(phoenix_w)

function phoenix_w:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1200)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    PointTargetProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target,
        speed = 700,
        graphics = "particles/phoenix_w/phoenix_w.vpcf",
        hitCondition = 
            function(self, target)
                return instanceof(target, Projectile) and self.owner.team ~= target.owner.team
            end,
        targetReachedFunction =
            function(projectile)
                hero:AreaEffect({
                    filter = Filters.Area(target, 200),
                    filterProjectiles = true,
                    damage = true,
                    modifier = { name = "modifier_phoenix_w", duration = 2.0, ability = self }
                })

                local particle = ImmediateEffect("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN, hero)
                ParticleManager:SetParticleControl(particle, 0, target)
                ParticleManager:SetParticleControl(particle, 1, Vector(200, 1, 1))

                hero:EmitSound("Arena.Phoenix.HitW", target)
            end
    }):Activate()

    hero:EmitSound("Arena.Phoenix.CastW")
end
