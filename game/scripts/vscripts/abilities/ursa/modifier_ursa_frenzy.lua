modifier_ursa_frenzy = class({})

if IsServer() then
    function modifier_ursa_frenzy:OnCreated()
        local hero = self:GetParent():GetParentEntity()
        hero:FindAbility("ursa_q"):EndCooldown()
        hero:EmitSound("Arena.Ursa.Frenzy")
    end

    function modifier_ursa_frenzy:OnDestroy()
        local hero = self:GetParent():GetParentEntity()

        hero:AddNewModifier(hero, hero:FindAbility("ursa_a"), "modifier_ursa_fury", {})
    end
end

function modifier_ursa_frenzy:GetEffectName()
    return "particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf"
end

function modifier_ursa_frenzy:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
