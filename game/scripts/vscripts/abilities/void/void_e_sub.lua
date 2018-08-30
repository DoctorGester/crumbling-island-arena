void_e_sub = class({})

function void_e_sub:OnSpellStart()
    Wrappers.DirectionalAbility(self, 600)

    local hero = self:GetCaster():GetParentEntity()
    local target = self:GetCursorPosition()

    FX("particles/econ/items/faceless_void/faceless_void_jewel_of_aeons/fv_time_walk_slow_jewel.vpcf", PATTACH_POINT, hero, {
        cp0 = { ent = hero, point = "attach_hitloc" },
        cp3 = { ent = hero, point = "attach_hitloc" },
        release = true
    })

    Dash(hero, target, 1800, {
        modifier = { name = "modifier_void_e", ability = self },
        forceFacing = true,
        gesture = ACT_DOTA_CAST_ABILITY_1,
        gestureRate = 2.5,
        hitParams = {
            ability = self,
            sound = "Arena.Void.HitE.Sub",
            action = function(target)
                target:Damage(hero, 2)
                target:AddNewModifier(hero, self, "modifier_void_e_slow", { duration = 2.0 })
            end
        }
    })

    hero:RemoveModifier("modifier_void_e_sub")
    hero:EmitSound("Arena.Void.CastE.Sub")
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(void_e_sub)