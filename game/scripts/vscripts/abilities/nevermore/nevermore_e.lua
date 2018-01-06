nevermore_e = class({})

LinkLuaModifier("modifier_nevermore_e", "abilities/nevermore/modifier_nevermore_e", LUA_MODIFIER_MOTION_NONE)

function nevermore_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 700)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    Dash(hero, target, 1200, {
        modifier = { name = "modifier_nevermore_e", ability = self },
        forceFacing = true,
        gesture = ACT_DOTA_FLAIL,
        gestureRate = 1.2,
        loopingSound = "Arena.Nevermore.CastE",
        hitParams = {
            ability = self,
            modifier = { name = "modifier_silence_lua", ability = self, duration = 2.0 },
            sound = "Arena.Nevermore.HitE"
        }
    })

    hero:EmitSound("Arena.Nevermore.CastE")
end

function nevermore_e:GetPlaybackRateOverride()
    return 2
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(nevermore_e)