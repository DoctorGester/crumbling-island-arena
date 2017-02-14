ta_w = class({})
LinkLuaModifier("modifier_ta_w", "abilities/ta/modifier_ta_w", LUA_MODIFIER_MOTION_NONE)

function ta_w:OnSpellStart()
    Wrappers.DirectionalAbility(self, 900)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    local effect = FX("particles/units/heroes/hero_templar_assassin/templar_assassin_trap.vpcf", PATTACH_WORLDORIGIN, hero, {
        cp0 = target,
        release = false
    })

    TimedEntity(0.9, function()
        DFX(effect)

        FX("particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf", PATTACH_WORLDORIGIN, hero, {
            cp0 = target,
            release = true
        })

        hero:EmitSound("Arena.TA.EndW", target)

        hero:AreaEffect({
            ability = self,
            onlyHeroes = true,
            filter = Filters.Area(target, 230),
            modifier = { name = "modifier_ta_w", duration = 3.5, ability = self }
        })
    end):Activate()

    hero:EmitSound("Arena.TA.CastW", target)
end

function ta_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end