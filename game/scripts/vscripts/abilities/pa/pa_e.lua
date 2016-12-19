pa_e = class({})

LinkLuaModifier("modifier_pa_e", "abilities/pa/modifier_pa_e", LUA_MODIFIER_MOTION_NONE)

function pa_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local modifier = hero:AddNewModifier(hero, self, "modifier_pa_e", { duration = 0.55 })
    hero:Animate(ACT_DOTA_CAST_ABILITY_2, 1.5)

    Timers:CreateTimer(0.1,
        function()
            self:GetCaster():Interrupt()
            Dash(hero, hero:GetPos() + hero:GetFacing() * 500, 1250, {
                heightFunction = DashParabola(80)
            }):SetModifierHandle(modifier)
        end
    )
end