drow_w = class({})

function drow_w:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1000)

    local hero = self:GetCaster():GetParentEntity()
    local target = self:GetCursorPosition()
    local particle = FX("particles/aoe_marker_filled.vpcf", PATTACH_ABSORIGIN, hero, {
        cp0 = target,
        cp1 = Vector(250, 0, 0),
        cp2 = Vector(194, 208, 210)
    })

    TimedEntity(0.55, function()
        DFX(particle)

        local hit = hero:AreaEffect({
            ability = self,
            filter = Filters.Area(target, 250),
            modifier = { name = "modifier_silence_lua", duration = 1.2, ability = self },
            onlyHeroes = true
        })

        if hit then
            hero:FindAbility("drow_q"):EndCooldown()
        end

        FX("particles/units/heroes/hero_drow/drow_silence.vpcf", PATTACH_WORLDORIGIN, hero, {
            cp0 = target,
            cp1 = Vector(250, 1, 1),
            release = true
        })

        hero:EmitSound("Arena.Drow.CastW")
    end):Activate()

    hero:EmitSound("Arena.Drow.CastW.Voice")
end

function drow_w:GetPlaybackRateOverride()
    return 2
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(drow_w)