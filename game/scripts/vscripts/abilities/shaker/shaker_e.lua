shaker_e = class({})

LinkLuaModifier("modifier_shaker_e", "abilities/shaker/modifier_shaker_e", LUA_MODIFIER_MOTION_NONE)

function shaker_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 550, 350)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local distance = (target - hero:GetPos()):Length2D() / 650

    hero:AddNewModifier(hero, hero:FindAbility("shaker_a"), "modifier_shaker_a", { duration = 5 })

    local effect = ParticleManager:CreateParticle("particles/shaker_e/shaker_e.vpcf", PATTACH_ABSORIGIN, hero:GetUnit())
    ParticleManager:SetParticleControl(effect, 0, target)
    ParticleManager:SetParticleControl(effect, 1, hero:GetPos() - self:GetDirection())
    ParticleManager:SetParticleControl(effect, 2, Vector(0.3, 0, 0))
    ParticleManager:ReleaseParticleIndex(effect)

    FunctionDash(hero, target, 0.4, {
        forceFacing = true,
        heightFunction = function(dash, current)
            local d = (dash.from - dash.to):Length2D()
            local x = (dash.from - current):Length2D()
            return ParabolaZ(160, d, x)
        end,
        arrivalFunction = function(dash)
            hero:AreaEffect({
                ability = self,
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

    hero:Animate(ACT_DOTA_OVERRIDE_ABILITY_2, 2.5 / distance)
    hero:EmitSound("Arena.Shaker.CastE")
    Spells:GroundDamage(hero:GetPos(), 200, hero)
end

function shaker_e:GetPlaybackRateOverride()
    return 2
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(shaker_e)