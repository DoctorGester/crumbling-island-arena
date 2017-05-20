drow_e = class({})
LinkLuaModifier("modifier_drow_e", "abilities/drow/modifier_drow_e", LUA_MODIFIER_MOTION_NONE)

function drow_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 400)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    Dash(hero, target, 1200, {
        modifier = { name = "modifier_drow_e", ability = self },
        forceFacing = true
    })

end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(drow_e)