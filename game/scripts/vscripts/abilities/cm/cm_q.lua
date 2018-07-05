cm_q = class({})

LinkLuaModifier("modifier_cm_frozen", "abilities/cm/modifier_cm_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cm_stun", "abilities/cm/modifier_cm_stun", LUA_MODIFIER_MOTION_NONE)

function cm_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1200)

    local hero = self:GetCaster():GetParentEntity()
    local target = self:GetCursorPosition()
    local particle = FX("particles/aoe_marker_filled.vpcf", PATTACH_ABSORIGIN, hero, {
        cp0 = target,
        cp1 = Vector(200, 0, 0),
        cp2 = Vector(175, 238, 238)
    })

    TimedEntity(0.7, function()
        DFX(particle)

        hero:AreaEffect({
            ability = self,
            damagesTrees = true,
            filter = Filters.Area(target, 200),
            action = function(victim)
                CMUtil.AbilityHit(hero, victim, self)
            end
        })

        ScreenShake(target, 5, 150, 0.25, 2000, 0, true)
        Spells:GroundDamage(target, 200, hero)

        FX("particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova.vpcf", PATTACH_WORLDORIGIN, hero, {
            cp0 = target,
            cp1 = Vector(200, 1, 1),
            release = true
        })

        FX("particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf", PATTACH_WORLDORIGIN, hero, {
            cp0 = target,
            cp1 = Vector(200, 1, 1),
            release = true
        })

        hero:EmitSound("Arena.CM.HitQ", target)
    end):Activate()

    hero:EmitSound("Arena.CM.CastQ")
end

function cm_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function cm_q:GetPlaybackRateOverride()
    return 1.66
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(cm_q)