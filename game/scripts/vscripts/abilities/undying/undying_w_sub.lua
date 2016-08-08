undying_w_sub = class({})

LinkLuaModifier("modifier_undying_w_sub", "abilities/undying/modifier_undying_w_sub", LUA_MODIFIER_MOTION_NONE)

function undying_w_sub:OnSpellStart()
    Wrappers.DirectionalAbility(self, 400)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    local dash = Dash(hero, target, 1400, {
        forceFacing = true,
        heightFunction = DashParabola(100),
        arrivalFunction = function(dash)
            hero:AreaEffect({
                filter = Filters.Area(target, 256),
                modifier = { name = "modifier_stunned_lua", duration = 0.4, ability = self },
            })

            hero:EmitSound("Arena.Undying.HitW.Sub")
            hero:GetUnit():StartGestureWithPlaybackRate(ACT_DOTA_FORCESTAFF_END, 1.66)

            ScreenShake(hero:GetPos(), 5, 150, 0.45, 3000, 0, true)
        end,
        modifier = { name = "modifier_undying_w_sub", ability = self },
    })

    hero:EmitSound("Arena.Undying.CastW.Sub")
end