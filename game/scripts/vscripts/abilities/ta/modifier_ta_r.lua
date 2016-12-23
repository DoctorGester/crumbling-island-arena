modifier_ta_r = class({})

if IsServer() then
    function modifier_ta_r:OnCreated()
        self:SetStackCount(3)

        local parent = self:GetParent()
        local index = FX("particles/units/heroes/hero_templar_assassin/templar_assassin_refraction.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent, {
            cp1 = { ent = parent, attach = PATTACH_ABSORIGIN_FOLLOW },
            cp4 = { ent = parent, attach = PATTACH_ABSORIGIN_FOLLOW },
            cp5 = { ent = parent, attach = PATTACH_ABSORIGIN_FOLLOW },
            release = false
        })

        self:AddParticle(index, false, false, -1, false, false)
    end

    function modifier_ta_r:OnDamageReceived(source, hero)
        hero:EmitSound("Arena.TA.HitR")

        self:DecrementStackCount()

        if self:GetStackCount() == 0 then
            self:Destroy()
        end

        return false
    end
end