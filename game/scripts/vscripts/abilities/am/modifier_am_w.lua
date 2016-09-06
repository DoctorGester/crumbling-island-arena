modifier_am_w = class({})
local self = modifier_am_w

function self:GetEffectName()
    return "particles/am_w/am_w_shield.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_ROOTBONE_FOLLOW
end

function self:OnModifierAdded(source, ability, modifier, params)
    if source.GetParentEntity then
        source = source:GetParentEntity()
    end

    local hero = self:GetParent():GetParentEntity()

    if source.owner.team ~= hero.owner.team then
        self.rejectedModifiers = self.rejectedModifiers or {}

        if not self.rejectedModifiers[modifier] then
            hero:FindModifier("modifier_charges"):RestoreCharge()
            hero:EmitSound("Arena.AM.HitW")

            if not self.voicePlayed then
                self.voicePlayed = true
                hero:EmitSound("Arena.AM.HitW.Voice")
            end

            self.rejectedModifiers[modifier] = true
        end

        return false
    end
end

if IsServer() then
    function self:OnDestroy()
        self:GetParent():GetParentEntity():EmitSound("Arena.AM.EndW")
    end
end