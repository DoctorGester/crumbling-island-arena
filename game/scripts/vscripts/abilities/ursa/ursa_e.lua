ursa_e = class({})

LinkLuaModifier("modifier_ursa_e", "abilities/ursa/modifier_ursa_e", LUA_MODIFIER_MOTION_NONE)

function ursa_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 600)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    Dash(hero, target, 1000, {
        modifier = { name = "modifier_ursa_e", ability = self },
        forceFacing = true,
        hitParams = {
            ability = self,
            modifier = { name = "modifier_stunned_lua", ability = self, duration = 0.4 }
        },
        arrivalFunction = function()
            hero:GetUnit():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1_END, 1.5)
            hero:EmitSound("Arena.Ursa.EndE")
            hero:EmitSound("Arena.Ursa.EndE.Voice")
            ScreenShake(hero:GetPos(), 5, 150, 0.45, 3000, 0, true)
        end,
        noFixedDuration = true,
        loopingSound = "Arena.Ursa.LoopE"
    })

    hero:EmitSound("Arena.Ursa.CastE")
end

function ursa_e:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function ursa_e:GetPlaybackRateOverride()
    return 1.5
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(ursa_e)