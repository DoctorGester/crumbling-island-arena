require("util")

modifier_ogre_r = GenericModifier(
    {
        GetEffectName = "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf",
        GetEffectAttachType = PATTACH_ABSORIGIN_FOLLOW,
        OnCreated = function(self)
            local unit = self:GetParent()
            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_cast.vpcf", PATTACH_POINT_FOLLOW, unit)

            for i = 1, 4 do
                ParticleManager:SetParticleControlEnt(particle, i, unit, PATTACH_POINT_FOLLOW, nil, unit:GetAbsOrigin(), true)
            end

            if IsServer() then
                self:StartIntervalThink(3.2)
            end
        end,
        OnIntervalThink = function(self)
            self:GetParent():EmitSound("Arena.Ogre.CastR")
            self:GetParent():EmitSound("Arena.Ogre.CastR2")
            self:GetParent():EmitSound("Arena.Ogre.CastR3")

            self:StartIntervalThink(-1)
        end
    },
    {},
    { MODIFIER_PROPERTY_MODEL_SCALE = 20, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT = 200 }
)