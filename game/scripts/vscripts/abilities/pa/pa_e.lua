pa_e = class({})

LinkLuaModifier("modifier_pa_e", "abilities/pa/modifier_pa_e", LUA_MODIFIER_MOTION_NONE)

function pa_e:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster():GetParentEntity()
    hero:EmitSound("Arena.PA.StepE")

    Dash(hero, hero:GetPos() + self:GetDirection() * 500, 1250, {
        forceFacing = true,
        modifier = { name = "modifier_pa_e", ability = self },
        heightFunction = DashParabola(80),
        gesture = ACT_DOTA_CAST_ABILITY_2,
        gestureRate = 1.8,
        arrivalFunction = function()
            FX("particles/units/heroes/hero_earthshaker/es_dust_hit.vpcf", PATTACH_ABSORIGIN, hero, { release = true })
            hero:EmitSound("Arena.PA.StepE")
        end
    })

    FX("particles/units/heroes/hero_earthshaker/earthshaker_totem_leap_impact_dust.vpcf", PATTACH_ABSORIGIN, hero, { release = true })
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(pa_e)