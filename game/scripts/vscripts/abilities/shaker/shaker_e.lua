shaker_e = class({})

LinkLuaModifier("modifier_shaker_e", "abilities/shaker/modifier_shaker_e", LUA_MODIFIER_MOTION_NONE)

function shaker_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 550, 350)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local distance = (target - hero:GetPos()):Length2D() / 650

    local effect = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_gravelmaw/earthshaker_fissure_head_gravelmaw.vpcf", PATTACH_ABSORIGIN, hero:GetUnit())
    ParticleManager:SetParticleControl(effect, 0, target)
    ParticleManager:SetParticleControl(effect, 1, hero:GetPos() - self:GetDirection())
    ParticleManager:SetParticleControl(effect, 2, Vector(0.3, 0, 0))
    ParticleManager:ReleaseParticleIndex(effect)

    local dash = Dash(hero, target, 1400, {
        forceFacing = true,
        heightFunction = function(dash, current)
            local d = (dash.from - dash.to):Length2D()
            local x = (dash.from - current):Length2D()
            return ParabolaZ(160, d, x)
        end,
        arrivalFunction = function(dash)
            hero:AreaEffect({
                filter = Filters.Area(target, 256),
                modifier = { name = "modifier_stunned_lua", duration = 0.4, ability = self },
            })

            hero:EmitSound("Arena.Shaker.HitE")

            local effect = ImmediateEffect("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_aftershock_egset.vpcf", PATTACH_ABSORIGIN, hero)
            ParticleManager:SetParticleControl(effect, 0, target)
            ParticleManager:SetParticleControl(effect, 1, Vector(256, 1, 1))

            --ScreenShake(hero:GetPos(), 2, 100, 0.15, 1500, 0, true)
        end,
        modifier = { name = "modifier_shaker_e", ability = self },
    })

    hero:EmitSound("Arena.Shaker.CastE")
    Spells:GroundDamage(hero:GetPos(), 200)

    dash.modifierHandle:SetStackCount(25 / distance)
end

function shaker_e:GetPlaybackRateOverride()
    return 2
end