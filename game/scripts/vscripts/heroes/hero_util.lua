LycanUtil = {}

function LycanUtil.IsTransformed(hero)
    return hero:FindModifier("modifier_lycan_r")
end

function LycanUtil.IsBleeding(target)
    return target:FindModifier("modifier_lycan_bleed")
end

function LycanUtil.MakeBleed(hero, target, ability)
    target:AddNewModifier(hero, ability, "modifier_lycan_bleed", { duration = 4 })

    local fear = target:FindModifier("modifier_lycan_e")

    if fear then
        fear.bleedingOccured = true
    end
end

EmberUtil = {}

function EmberUtil.IsBurning(target)
    return target:HasModifier("modifier_ember_burning")
end

function EmberUtil.Burn(hero, target, ability)
    if EmberUtil.IsBurning(target) then
        target:RemoveModifier("modifier_ember_burning")
        target:EmitSound("Arena.Ember.HitCombo")
        return true
    end

    target:AddNewModifier(hero, ability, "modifier_ember_burning", { duration = 2.0 })
    return false
end

SvenUtil = {}

function SvenUtil.IsEnraged(hero)
    return hero:FindModifier("modifier_sven_r")
end