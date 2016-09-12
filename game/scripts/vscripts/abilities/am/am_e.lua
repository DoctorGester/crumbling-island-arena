am_e = class({})
local self = am_e

LinkLuaModifier("modifier_am_e", "abilities/am/modifier_am_e", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    Wrappers.DirectionalAbility(self, 450, 450)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    Dash(hero, target, 2000, {
        modifier = { name = "modifier_am_e", ability = self },
        forceFacing = true,
        hitParams = {
            action = function(victim)
                hero:FindAbility("am_q"):DealDamage(victim)
            end
        }
    })

    hero:EmitSound("Arena.AM.CastE")
end

function self:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function self:GetPlaybackRateOverride()
    return 2
end