gyro_e = class({})
local self = gyro_e

LinkLuaModifier("modifier_gyro_e", "abilities/gyro/modifier_gyro_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gyro_e_cooldown", "abilities/gyro/modifier_gyro_e_cooldown", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local length = (target - hero:GetPos()):Length2D()

    local dash = Dash(hero, target, 1200, {
        forceFacing = true,
        heightFunction = function(dash, current)
            local d = (dash.from - dash.to):Length2D()
            local x = (dash.from - current):Length2D()
            return ParabolaZ(math.min(length / 1200, 1) * 460, d, x)
        end,
        loopingSound = "Arena.Gyro.LoopE",
        modifier = { name = "modifier_gyro_e", ability = self },
    })

    hero:EmitSound("Arena.Gyro.CastE")
    hero:EmitSound("Arena.Gyro.CastE.Voice")
    FX("particles/units/heroes/hero_gyrocopter/gyro_guided_missle_explosion_fire.vpcf", PATTACH_ABSORIGIN, hero, { release = true })
end

function self:GetIntrinsicModifierName()
    return "modifier_gyro_e_cooldown"
end
