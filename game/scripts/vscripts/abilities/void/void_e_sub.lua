void_e_sub = class({})

function void_e_sub:OnSpellStart()
    Wrappers.DirectionalAbility(self, 600)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    FX("particles/econ/items/faceless_void/faceless_void_jewel_of_aeons/fv_time_walk_slow_jewel.vpcf", PATTACH_POINT, self:GetCaster(), {
        cp0 = { ent = self:GetCaster(), point = "attach_hitloc" },
        cp3 = { ent = self:GetCaster(), point = "attach_hitloc" },
        release = true
    })

    Dash(hero, target, 1800, {
        modifier = { name = "modifier_void_e", ability = self },
        forceFacing = true,
        gesture = ACT_DOTA_CAST_ABILITY_1,
        gestureRate = 2.5,
        hitParams = {
            ability = self,
            action = function(target)
                target:Damage(hero, 2)
                target:AddNewModifier(hero, self, "modifier_void_e_slow", { duration = 2.0 })
            end
        }
    })

    hero:RemoveModifier("modifier_void_e_sub")
    hero:EmitSound("Arena.Void.CastE.Sub")
end

--[[function void_e:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function void_e:GetPlaybackRateOverride()
    return 2.5
end]]--

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(void_e_sub)