modifier_ta_r_shield = class({})

if IsServer() then
    function modifier_ta_r_shield:OnCreated(kv)
        local index = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_refraction.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControlEnt(index, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true)
        ParticleManager:SetParticleControlEnt(index, 4, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true)
        ParticleManager:SetParticleControlEnt(index, 5, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true)
        self:AddParticle(index, false, false, -1, false, false)
    end

    function modifier_ta_r_shield:OnDamageReceived(source, hero)
        hero:EmitSound("Arena.TA.HitR")
        hero:AddNewModifier(hero, self:GetAbility(), "modifier_ta_r_heal", { duration = 3 })

        return true
    end
end