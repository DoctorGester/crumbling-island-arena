tiny_w = class({})

require('abilities/tiny/tiny_w_entity')

function tiny_w:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("Arena.Tiny.CastW")
    return true
end

function tiny_w:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1500)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    local mod = hero:FindModifier("modifier_tiny_r")

    if mod and not mod.used then
        local dist = (target - hero:GetPos()):Length2D()
        local tilt = 1 - dist / 2000

        for i = -1, 1 do
            local dir = self:GetDirection()
            local an = math.atan2(dir.y, dir.x) + (0.3 + 0.8 * i * tilt)
            local retarget = Vector(math.cos(an), math.sin(an)) * dist + hero:GetPos()

            TimedEntity((i + 1) * 0.1, function()
                TinyW(hero.round, hero, self, self:GetDamage(), retarget, 2, 600):Activate()
            end):Activate()
        end

        mod:Use()
    else
        TinyW(hero.round, hero, self, self:GetDamage(), target, 2, 600):Activate()
    end
end

function tiny_w:GetCastAnimation()
    return ACT_TINY_TOSS
end

function tiny_w:GetPlaybackRateOverride()
    return 2
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(tiny_w)