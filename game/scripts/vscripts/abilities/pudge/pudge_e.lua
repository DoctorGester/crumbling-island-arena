pudge_e = class({})

LinkLuaModifier("modifier_pudge_e_animation", "abilities/pudge/modifier_pudge_e_animation", LUA_MODIFIER_MOTION_NONE)

function pudge_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 650)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = self:GetDirection()

    local dash = Dash(hero, target, 1200, {
        modifier = { name = "modifier_pudge_e_animation", ability = self }
    })

    dash.hitParams = {
        modifier = { name = "modifier_stunned_lua", ability = self, duration = 0.7 },
        action = function(target)
            Knockback(target, self, direction, 500, 1500, DashParabola(50))
            ScreenShake(target:GetPos(), 5, 150, 0.45, 3000, 0, true)

            hero:EmitSound("Arena.Pudge.HitE")

            dash:Interrupt()
        end
    }
end

function pudge_e:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function pudge_e:GetPlaybackRateOverride()
    return 2
end