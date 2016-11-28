modifier_slark_a = class({})

if IsServer() then
    function modifier_slark_a:SetTarget(target)
        self.target = target
    end

    function modifier_slark_a:OnDestroy()
        if self.purged or not self.target:Alive() then
            return
        end

        local color = Vector(161, 127, 255)
        local hero = self:GetParent().hero
        
        if hero:GetHealth() > 1 then
            hero:Damage(hero, 1)
        end

        self.target:Heal(1)

        hero:EmitSound("Arena.Slark.EndA")

        local index = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.target.unit)
        ParticleManager:SetParticleControlEnt(index, 0, self.target:GetUnit(), PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetPos(), true)
        ParticleManager:SetParticleControlEnt(index, 1, hero:GetUnit(), PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetPos(), true)

        for _, cp in pairs({ 10, 11, 15, 16 }) do
            ParticleManager:SetParticleControl(index, cp, color)
        end
    end

    function modifier_slark_a:SetPurged(purged)
        self.purged = purged
    end
end

function modifier_slark_a:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_slark_a:IsDebuff()
    return true
end