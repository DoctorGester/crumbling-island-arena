modifier_qop_q = class({})

if IsServer() then
    function modifier_qop_q:OnCreated(kv)
        self:StartIntervalThink(self:GetDuration())

        local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_shadow_strike_debuff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())

        for _, cp in pairs({ 0, 2, 3 }) do
            ParticleManager:SetParticleControlEnt(effect, cp, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
        end

        self:AddParticle(effect, false, false, 0, true, false)

        self.heals = kv.heals ~= 0
    end

    function modifier_qop_q:OnIntervalThink()
        self:GetParent():GetParentEntity():Damage(self:GetCaster().hero)

        if self.heals and self:GetCaster():GetParentEntity():Alive() then
            self:GetCaster().hero:Heal()
            self:GetCaster():EmitSound("Arena.QOP.CastR.Heal")
        end
    end
end

function modifier_qop_q:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_qop_q:IsDebuff()
    return true
end

function modifier_qop_q:GetModifierMoveSpeedBonus_Percentage(params)
    return -20
end

function modifier_qop_q:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
