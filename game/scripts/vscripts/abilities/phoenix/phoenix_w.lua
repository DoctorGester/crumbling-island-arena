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

    local projectileData = {}
    projectileData.owner = hero
    projectileData.from = hero:GetPos() + Vector(0, 0, 128)
    projectileData.to = target
    projectileData.velocity = 700
    projectileData.graphics = "particles/phoenix_w/phoenix_w.vpcf"
    projectileData.endPoint = target
    projectileData.radius = 64

    projectileData.onTargetReached =
        function(projectile)
            local particle = ImmediateEffect("particles/units/heroes/hero_phoenix/phoenix_fire_spirit_ground.vpcf", PATTACH_ABSORIGIN, hero)
            ParticleManager:SetParticleControl(particle, 0, target)
            ParticleManager:SetParticleControl(particle, 1, Vector(200, 1, 1))

            Spells:AreaModifier(hero, ability, "modifier_phoenix_w", { duration = 2.0 }, target, 200,
                function (hero, target)
                    return hero ~= target
                end
            )

            Spells:AreaDamage(hero, target, 200)
            hero:EmitSound("Arena.Phoenix.HitW", target)

            projectile:Destroy()
        end

    projectileData.heroCondition = function() return false end

    Spells:CreateProjectile(projectileData)
    hero:EmitSound("Arena.Phoenix.CastW")
end
