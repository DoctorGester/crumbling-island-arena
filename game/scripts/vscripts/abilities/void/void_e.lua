void_e = class({})

LinkLuaModifier("modifier_void", "abilities/void/modifier_void", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_void_e", "abilities/void/modifier_void_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_void_e_sub", "abilities/void/modifier_void_e_sub", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_void_e_disarm", "abilities/void/modifier_void_e_disarm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_void_e_animation", "abilities/void/modifier_void_e_animation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_void_e_slow", "abilities/void/modifier_void_e_slow", LUA_MODIFIER_MOTION_NONE)

function void_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 600)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local mod = hero:FindModifier("modifier_void")
    local hp = mod:TimeWalkHP()

    if hp > hero:GetHealth() then
        hero:Heal(hp - hero:GetHealth())
    end

    FX("particles/econ/items/faceless_void/faceless_void_jewel_of_aeons/fv_time_walk_slow_jewel.vpcf", PATTACH_POINT, self:GetCaster(), {
        cp0 = { ent = self:GetCaster(), point = "attach_hitloc" },
        cp3 = { ent = self:GetCaster(), point = "attach_hitloc" },
        release = true
    })

    Dash(hero, target, 1800, {
        modifier = { name = "modifier_void_e_animation", ability = self },
        forceFacing = true,
        gesture = ACT_DOTA_CAST_ABILITY_1,
        gestureRate = 2.5,
        hitParams = {
            ability = self,
            action = function(target)
                if instanceof(target, Hero) then
                    if hero:FindAbility("void_e_sub"):IsHidden() then
                        hero:SwapAbilities("void_e", "void_e_sub")
                    end
                    hero:AddNewModifier(hero, self, "modifier_void_e_sub", { duration = 2.0 })
                    target:AddNewModifier(hero, self, "modifier_void_e_disarm", { duration = 2.0 })
                end
            end
        }
    })
    ImmediateEffect("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere_flash.vpcf", PATTACH_ABSORIGIN, hero)
    hero:EmitSound("Arena.Void.CastE")
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(void_e)