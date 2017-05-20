tusk_e = class({})

LinkLuaModifier("modifier_tusk_e", "abilities/tusk/modifier_tusk_e", LUA_MODIFIER_MOTION_NONE)

function tusk_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1200)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local speed = 600

    if hero:HasModifier("modifier_tusk_r") then
        speed = 1200
    end

    Dash(hero, target, speed, {
        forceFacing = true,
        modifier = { name = "modifier_tusk_e", ability = self },
        hitParams = {
            ability = self,
            modifier = { name = "modifier_stunned_lua", ability = self, duration = 1.2 },
            sound = "Arena.Tusk.HitE"
        },
        loopingSound = "Arena.Tusk.LoopE",
        arrivalSound = "Arena.Tusk.EndE"
    })

    hero:EmitSound("Arena.Tusk.CastE")
end

function tusk_e:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function tusk_e:GetPlaybackRateOverride()
    return 2
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(tusk_e)