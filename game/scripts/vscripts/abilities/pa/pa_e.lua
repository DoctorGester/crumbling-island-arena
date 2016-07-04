pa_e = class({})

LinkLuaModifier("modifier_pa_e", "abilities/pa/modifier_pa_e", LUA_MODIFIER_MOTION_NONE)

function pa_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local modifier = hero:AddNewModifier(hero, self, "modifier_pa_e", { duration = 0.55 })
    StartAnimation(hero:GetUnit(), { duration = 0.7, activity = ACT_DOTA_CAST_ABILITY_2, rate = 1.35 })

    Timers:CreateTimer(0.15,
        function()
            self:GetCaster():Interrupt()
            Dash(hero, hero:GetPos() + hero:GetFacing() * 400, 1000, {
                heightFunction = function(dash, current)
                    local d = (dash.from - dash.to):Length2D()
                    local x = (dash.from - current):Length2D()
                    return ParabolaZ(80, d, x)
                end
            }):SetModifierHandle(modifier)
        end
    )
end