void_e = class({})

LinkLuaModifier("modifier_void", "abilities/void/modifier_void", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_void_e", "abilities/void/modifier_void_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_void_e_sub", "abilities/void/modifier_void_e_sub", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_void_e_disarm", "abilities/void/modifier_void_e_disarm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_void_e_slow", "abilities/void/modifier_void_e_slow", LUA_MODIFIER_MOTION_NONE)

function void_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 600)

    local hero = self:GetCaster():GetParentEntity()
    local target = self:GetCursorPosition()
    local mod = hero:FindModifier("modifier_void")
    local hp = mod:TimeWalkHP()
    local abilityAlreadySwapped = false

    if hp > hero:GetHealth() then
        hero:Heal(hp - hero:GetHealth())
    end

    local function swapToSubAbilityIfNotAlreadySwapped()
        if not abilityAlreadySwapped then
            if hero:FindAbility("void_e_sub"):IsHidden() then
                hero:SwapAbilities("void_e", "void_e_sub")
            end

            hero:AddNewModifier(hero, self, "modifier_void_e_sub", { duration = 2.0 })

            abilityAlreadySwapped = true
        end
    end

    FX("particles/econ/items/faceless_void/faceless_void_jewel_of_aeons/fv_time_walk_slow_jewel.vpcf", PATTACH_POINT, hero, {
        cp0 = { ent = hero, point = "attach_hitloc" },
        cp3 = { ent = hero, point = "attach_hitloc" },
        release = true
    })

    FX("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere_flash.vpcf", PATTACH_ABSORIGIN, hero, {
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
                if instanceof(target, Hero) then
                    swapToSubAbilityIfNotAlreadySwapped()

                    hero:EmitSound("Arena.Void.HitE")

                    TimedEntity(0, function()
                        hero:StopSound("Arena.Void.HitE")
                    end):Activate()

                    target:AddNewModifier(hero, self, "modifier_void_e_disarm", { duration = 2.0 })
                end
            end
        }
    })

    hero:EmitSound("Arena.Void.CastE")
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(void_e)