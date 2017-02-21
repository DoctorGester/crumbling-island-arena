am_e = class({})
local self = am_e

LinkLuaModifier("modifier_am_e", "abilities/am/modifier_am_e", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    Wrappers.DirectionalAbility(self, 450, 450)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    Dash(hero, target, 2000, {
        ability = self,
        modifier = { name = "modifier_am_e", ability = self },
        forceFacing = true,
        gesture = ACT_DOTA_RUN,
        gestureRate = 2.4,
        hitParams = {
            damage = self:GetDamage(),
            sound = "Arena.AM.Hit",
            action = function(target)
                if instanceof(target, Hero) then
                    hero:AddNewModifier(hero, hero:FindAbility("am_a"), "modifier_am_a", { duration = 3.0 })
                end
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

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(am_e)