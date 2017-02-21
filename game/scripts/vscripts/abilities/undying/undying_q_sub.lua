undying_q_sub = class({})

LinkLuaModifier("modifier_undying_q_sub", "abilities/undying/modifier_undying_q_sub", LUA_MODIFIER_MOTION_NONE)

function undying_q_sub:OnSpellStart()
    local hero = self:GetCaster():GetParentEntity()
    local stacks = self:GetCaster():GetModifierStackCount("modifier_undying_q_health", hero:GetUnit())

    Wrappers.DirectionalAbility(self, 400 + stacks * 60)

    local target = self:GetCursorPosition()

    ScreenShake(hero:GetPos(), 5, 150, 0.45, 3000, 0, true)

    Dash(hero, target, 1400 + stacks * 140, {
        forceFacing = true,
        heightFunction = DashParabola(100),
        gesture = ACT_DOTA_FLAIL,
        arrivalFunction = function(dash)
            hero:AreaEffect({
                ability = self,
                filter = Filters.Area(target, 256),
                modifier = { name = "modifier_stunned_lua", duration = 0.4 + 0.2 * stacks, ability = self },
            })

            hero:EmitSound("Arena.Undying.HitW.Sub")
            hero:Animate(ACT_DOTA_FORCESTAFF_END, 1.66)

            ScreenShake(hero:GetPos(), 5, 150, 0.45, 3000, 0, true)
        end,
        modifier = { name = "modifier_undying_q_sub", ability = self },
    })

    hero:EmitSound("Arena.Undying.CastW.Sub")
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(undying_q_sub)