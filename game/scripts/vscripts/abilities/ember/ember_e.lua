ember_e = class({})
LinkLuaModifier("modifier_ember_e", "abilities/ember/modifier_ember_e", LUA_MODIFIER_MOTION_NONE)

function ember_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 400)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    Dash(hero, target, 1800, {
        modifier = { name = "modifier_ember_e", ability = self },
        forceFacing = true,
        hitParams = {
            action = function(target)
                if EmberUtil.Burn(hero, target, self) then
                    target:Damage(hero)
                end
            end
        }
    })

    hero:EmitSound("Arena.Ember.CastE")
end

function ember_e:GetCastAnimation()
    return 0
end