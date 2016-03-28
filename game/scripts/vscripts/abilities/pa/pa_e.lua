pa_e = class({})

LinkLuaModifier("modifier_pa_e", "abilities/pa/modifier_pa_e", LUA_MODIFIER_MOTION_NONE)

function pa_e:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:AddNewModifier(hero, self, "modifier_pa_e", {})
    StartAnimation(hero:GetUnit(), { duration = 0.7, activity = ACT_DOTA_CAST_ABILITY_2 })

    Timers:CreateTimer(0.3,
        function()
            Dash(hero, hero:GetPos() + hero:GetFacing() * 400, 1000, {
                heightFunction = function(dash, current)
                    local d = (dash.from - dash.to):Length2D()
                    local x = (dash.from - current):Length2D()
                    return ParabolaZ(50, d, x)
                end,
                arrivalFunction = function(dash)
                    hero:RemoveModifier("modifier_pa_e")
                end
            })
        end
    )
end