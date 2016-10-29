modifier_lycan_instinct = class({})

function modifier_lycan_instinct:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_lycan_instinct:OnIntervalThink()
    local feelingBlood = false
    local hero = self:GetParent().hero
    local heroFacing = hero:GetFacing()
    local facing = VectorToAngles(heroFacing)

    for _, target in pairs(hero.round.spells:GetHeroTargets()) do

        if target ~= hero then
            local direction = (target:GetPos() - hero:GetPos()):Normalized()
            local angle = VectorToAngles(direction)
            local delta = RotationDelta(facing, angle).y

            if LycanUtil.IsBleeding(target) and delta < 30 and delta > -30 then
                feelingBlood = true
                break
            end
        end
    end

    local previousState = self:GetStackCount() ~= 0

    if previousState ~= feelingBlood then
        if feelingBlood then
            self.visual = ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
        else
            ParticleManager:DestroyParticle(self.visual, false)
            ParticleManager:ReleaseParticleIndex(self.visual)
        end
    end

    if feelingBlood then
        self:SetStackCount(1)
    else
        self:SetStackCount(0)
    end
end

function modifier_lycan_instinct:GetTexture()
    return "bloodseeker_thirst"
end

function modifier_lycan_instinct:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_lycan_instinct:GetModifierMoveSpeedBonus_Percentage(params)
    return self:GetStackCount() * 50
end

function modifier_lycan_instinct:IsHidden()
    return self:GetStackCount() == 0
end