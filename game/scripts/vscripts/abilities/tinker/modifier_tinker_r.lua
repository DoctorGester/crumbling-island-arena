modifier_tinker_r = class({})

function modifier_tinker_r:CheckState()
    local state = {
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end

if IsServer() then
    function modifier_tinker_r:OnCreated(params)
        self:StartIntervalThink(4.0)

        local particle = ParticleManager:CreateParticle("particles/aoe_marker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

        ParticleManager:SetParticleControl(particle, 1, Vector(400, 1, 1))
        ParticleManager:SetParticleControl(particle, 2, Vector(255, 178, 127))
        ParticleManager:SetParticleControl(particle, 3, Vector(10000, 0, 0))
        self:AddParticle(particle, false, false, 0, true, false)

        self:GetParent():EmitSound("Arena.Tinker.LoopR")
    end

    function modifier_tinker_r:OnIntervalThink()
        local pos = self:GetParent():GetAbsOrigin()
        local hero = self:GetCaster().hero

        if hero:Alive() and (hero:GetPos() - pos):Length2D() <= 400 then
            local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_attack.vpcf", PATTACH_ABSORIGIN, self:GetParent())
            ParticleManager:SetParticleControlEnt(effect, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", pos, true)
            ParticleManager:SetParticleControlEnt(effect, 1, hero:GetUnit(), PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetPos(), true)

            hero:FindAbility("tinker_q"):EndCooldown()
            hero:FindAbility("tinker_w"):EndCooldown()
            hero:FindAbility("tinker_e"):EndCooldown()

            self:GetParent():EmitSound("Arena.Tinker.HitR")
        end
    end

    function modifier_tinker_r:OnDestroy()
        self:GetParent():StopSound("Arena.Tinker.LoopR")
    end
end

function modifier_tinker_r:GetEffectName()
    return "particles/units/heroes/hero_rattletrap/rattletrap_cog_ambient.vpcf"
end

function modifier_tinker_r:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end