phoenix_q = class({})

LinkLuaModifier("modifier_phoenix_q", "abilities/phoenix/modifier_phoenix_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phoenix_q_slow", "abilities/phoenix/modifier_phoenix_q_slow", LUA_MODIFIER_MOTION_NONE)

if IsClient() then
    require("heroes/phoenix")
end

phoenix_q.CastFilterResult = Phoenix.CastFilterResultLocation
phoenix_q.GetCustomCastError = Phoenix.GetCustomCastErrorLocation

function phoenix_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = hero:GetPos() + hero:GetFacing() * 900

    hero:AddNewModifier(hero, self, "modifier_phoenix_q", {})

    if hero:GetHealth() > 1 then
        hero:Damage(hero)
    end

    local damaged = {}
    local dashData = {}
    dashData.hero = hero
    dashData.to = target
    dashData.velocity = 900
    dashData.onArrival =
        function (hero)
            hero:StopSound("Arena.Phoenix.CastQ")
            hero:RemoveModifier("modifier_phoenix_q")
        end

    dashData.positionFunction =
        function(position, data)
            local diff = data.to - position

            Spells:AreaModifier(hero, self, "modifier_phoenix_q_slow", { duration = 1.5 }, hero:GetPos(), 128,
                function (hero, target)
                    return hero ~= target
                end
            )

            Spells:MultipleHeroesDamage(hero,
                function (attacker, target)
                    local distance = (target:GetPos() - position):Length2D()

                    local damage = not damaged[target] and target ~= attacker and distance <= 128

                    if damage then
                        damaged[target] = true
                    end

                    return damage
                end
            )

            return position + (diff:Normalized() * data.velocity)
        end

    Spells:Dash(dashData)
    hero:EmitSound("Arena.Phoenix.CastQ")
end