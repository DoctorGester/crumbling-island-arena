phoenix_w = class({})

LinkLuaModifier("modifier_phoenix_w", "abilities/phoenix/modifier_phoenix_w", LUA_MODIFIER_MOTION_NONE)

function phoenix_w:OnAbilityPhaseStart()
    return not self:GetCaster():HasModifier("modifier_phoenix_egg")
end

if IsClient() then
    require("heroes/phoenix")
end

phoenix_w.CastFilterResultLocation = Phoenix.CastFilterResultLocation
phoenix_w.GetCustomCastErrorLocation = Phoenix.GetCustomCastErrorLocation

function phoenix_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()
    local ability = self

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    PointTargetProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target,
        speed = 700,
        graphics = "particles/phoenix_w/phoenix_w.vpcf",
        hitCondition = 
            function(self, target)
                return instanceof(target, Projectile)
            end,
        targetReachedFunction =
            function(self)
                hero:AreaEffect({
                    filter = Filters.Area(target, 200),
                    filterProjectiles = true,
                    damage = true,
                    modifier = { name = "modifier_phoenix_w", duration = 2.0, ability = self },
                    action = function()
                        local particle = ImmediateEffect("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN, hero)
                        ParticleManager:SetParticleControl(particle, 0, target)
                        ParticleManager:SetParticleControl(particle, 1, Vector(200, 1, 1))

                        hero:EmitSound("Arena.Phoenix.HitW", target)
                    end
                })
            end
    }):Activate()

    hero:EmitSound("Arena.Phoenix.CastW")
end
