lc_e = class({})

LinkLuaModifier("modifier_lc_e", "abilities/lc/modifier_lc_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lc_e_animation", "abilities/lc/modifier_lc_e_animation", LUA_MODIFIER_MOTION_NONE)

function lc_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = hero:GetPos() + hero:GetFacing() * hero.unit:GetIdealSpeed()

    hero:AddNewModifier(hero, self, "modifier_lc_e_animation", {})

    local dashData = {}
    dashData.hero = hero
    dashData.to = target
    dashData.velocity = 1200
    dashData.onArrival =
        function (hero)
            hero:RemoveModifier("modifier_lc_e_animation")
        end

    dashData.positionFunction =
        function(position, data)
            local diff = data.to - position

            Spells:AreaModifier(hero, self, "modifier_lc_e", { duration = 0.7 }, hero:GetPos(), 128,
                function (hero, target)
                    return hero ~= target
                end
            )

            return position + (diff:Normalized() * data.velocity)
        end

    Spells:Dash(dashData)
    hero:EmitSound("Arena.LC.CastE")
end