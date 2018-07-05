ability_blink = class({})

function ability_blink:OnSpellStart()
    local hero = self:GetCaster():GetParentEntity()

    Wrappers.DirectionalAbility(self, function()
        return hero:HasModifier("modifier_falling") and 500 or 250
    end)

    local target = self:GetCursorPosition()

    hero:EmitSound("Arena.AbilityBlink")
    hero:GetUnit():Interrupt()
    hero:SetFacing(self:GetDirection())

    if hero.falling then
        hero.fallingSpeed = 0

        if hero:TestFalling(target) then
            hero.falling = false
            hero:FindClearSpace(target, true)
            hero.round.spells:InterruptDashes(hero)
            hero:RemoveModifier("modifier_falling")
            hero:EmitSound("Arena.AbilityBlink.Save")

            EmitAnnouncerSound("Announcer.RoundDodge")
        else
            hero:SetPos(Vector(target.x, target.y, hero:GetPos().z))
        end
    else
        hero:FindClearSpace(target, true)
        hero.round.spells:InterruptDashes(hero)
    end

    FX("particles/ability_blink/ability_blink.vpcf", PATTACH_ABSORIGIN, hero, { release = true })
end

function ability_blink:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function ability_blink:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function ability_blink:GetPlaybackRateOverride()
    return 2
end