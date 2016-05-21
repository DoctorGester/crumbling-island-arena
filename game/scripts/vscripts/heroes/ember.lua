Ember = class({}, {}, Hero)

LinkLuaModifier("modifier_ember_burning", "abilities/ember/modifier_ember_burning", LUA_MODIFIER_MOTION_NONE)

function Ember:IsInvulnerable()
    return self.invulnerable or self:HasModifier("modifier_ember_e")
end

function Ember:IsBurning(target)
    return target:HasModifier("modifier_ember_burning")
end

function Ember:Burn(target, ability)
    if self:IsBurning(target) then
        target:RemoveModifier("modifier_ember_burning")
        target:EmitSound("Arena.Ember.HitCombo")
        return true
    end

    target:AddNewModifier(self, ability, "modifier_ember_burning", { duration = 2.0 })
    return false
end
