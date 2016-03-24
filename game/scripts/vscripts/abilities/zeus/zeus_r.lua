zeus_r = class({})
LinkLuaModifier("modifier_zeus_r", "abilities/zeus/modifier_zeus_r", LUA_MODIFIER_MOTION_NONE)

function zeus_r:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local ability = self

    hero:EmitSound("Hero_Zuus.GodsWrath.PreCast")

    Timers:CreateTimer(1.6,
        function()
            GridNav:DestroyTreesAroundPoint(target, 256, true)

            local particle = ImmediateEffect("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_POINT, hero)
            ParticleManager:SetParticleControl(particle, 0, target)
            ParticleManager:SetParticleControl(particle, 1, target + Vector(0, 0, 2000))

            particle = ImmediateEffect("particles/econ/items/zeus/lightning_weapon_fx/zuus_lightning_bolt_groundfx_crack.vpcf", PATTACH_POINT, hero)
            ParticleManager:SetParticleControl(particle, 3, target)

            hero:AreaEffect({
                filter = Filters.Area(target, 256),
                filterProjectiles = true,
                damage = true,
                modifier = { name = "modifier_zeus_r", duration = 4.5, ability = self },
                action = function(target)
                    local to = target:GetPos()
                    local particle = ImmediateEffect("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_CUSTOMORIGIN, hero)
                    ParticleManager:SetParticleControl(particle, 0, to + Vector(0, 0, 64))
                    ParticleManager:SetParticleControl(particle, 1, to)
                end
            })

            Spells:GroundDamage(target, 256)

            EmitSoundOnLocationWithCaster(target, "Hero_Zuus.GodsWrath.Target", nil)
        end
    )
end

function zeus_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end