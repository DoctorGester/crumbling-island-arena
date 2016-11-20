drow_q = class({})
LinkLuaModifier("modifier_drow_q", "abilities/drow/modifier_drow_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_drow_q_recast", "abilities/drow/modifier_drow_q_recast", LUA_MODIFIER_MOTION_NONE)

function drow_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 400, 400)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    Dash(hero, target, 1200, {
        modifier = { name = "modifier_drow_q", ability = self },
        forceFacing = true
    })

    local mod = hero:FindModifier("modifier_drow_q_recast")
    if mod then
        mod:Destroy()
    else
        hero:AddNewModifier(hero, self, "modifier_drow_q_recast", { duration = 3.0 })
        self:EndCooldown()
    end
end