drow_e = class({})
LinkLuaModifier("modifier_drow_e", "abilities/drow/modifier_drow_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drow_e_slow", "abilities/drow/modifier_drow_e_slow", LUA_MODIFIER_MOTION_NONE)

function drow_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 700)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    Dash(hero, target, 1200, {
        modifier = { name = "modifier_drow_e", ability = self },
        forceFacing = true,
        hitParams = {
            modifier = { name = "modifier_drow_e_slow", ability = self, duration = 2.0 },
        },
        loopingSound = "Arena.Drow.CastE"
    })
end