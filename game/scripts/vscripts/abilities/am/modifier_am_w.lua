modifier_am_w = class({})
local self = modifier_am_w

function self:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function self:GetModifierMoveSpeedBonus_Percentage(params)
    return -50
end

function self:GetEffectName()
    return "particles/am_w/am_w_shield.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_ROOTBONE_FOLLOW
end

function self:AllowAbilityEffect(source, ability)
    local hero = self:GetParent():GetParentEntity()

    if source.owner.team ~= hero.owner.team and not IsAttackAbility(ability) then
        self.soundLastPlayed = self.soundLastPlayed or 0

        if GameRules:GetGameTime() - self.soundLastPlayed > 0.2 then
            self.soundLastPlayed = GameRules:GetGameTime()

            hero:EmitSound("Arena.AM.HitW")
        end

        if not self.bonusGranted then
            self.bonusGranted = true
            hero:EmitSound("Arena.AM.HitW.Voice")
            hero:AddNewModifier(hero, hero:FindAbility("am_a"), "modifier_am_a", { duration = 3.0 })
        end

        return false
    end

    return true
end

if IsServer() then
    function self:OnDestroy()
        self:GetParent():GetParentEntity():EmitSound("Arena.AM.EndW")
    end
end