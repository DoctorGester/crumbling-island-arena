modifier_invoker_e = class({})

if IsServer() then
    function modifier_invoker_e:OnCreated(kv)
        local particle = ParticleManager:CreateParticle("particles/aoe_marker.vpcf", PATTACH_ABSORIGIN, self:GetParent())

        ParticleManager:SetParticleControl(particle, 1, Vector(400, 1, 1))
        ParticleManager:SetParticleControl(particle, 2, Vector(195, 143, 200))
        ParticleManager:SetParticleControl(particle, 3, Vector(self:GetDuration(), 0, 0))
        self:AddParticle(particle, false, false, 0, true, false)

        self:GetParent():EmitSound("Arena.Invoker.CastE")
        self:GetParent():EmitSound("Arena.Invoker.LoopE")
    end

    function modifier_invoker_e:OnAbilityExecuted(event)
        local hero = event.unit.hero
        local parent = self:GetParent()

        if hero and hero.owner.team ~= parent.hero.owner.team and (hero:GetPos() - parent:GetAbsOrigin()):Length2D() <= 400 then
            self:Destroy()
        end
    end

    function modifier_invoker_e:OnDestroy()
        local parent = self:GetParent()

        parent.hero:AreaEffect({
            filter = Filters.Area(parent:GetAbsOrigin(), 400),
            filterProjectiles = true,
            onlyHeroes = true,
            modifier = {
                name = "modifier_silence_lua",
                duration = 2.0,
                ability = self:GetAbility()
            }
        })

        self:GetParent():StopSound("Arena.Invoker.LoopE")
        self:GetParent():EmitSound("Arena.Invoker.EndE")
    end
end

function modifier_invoker_e:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_VISUAL_Z_DELTA,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }

    return funcs
end

function modifier_invoker_e:GetEffectName()
    return "particles/units/heroes/hero_invoker/invoker_emp.vpcf"
end

function modifier_invoker_e:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_invoker_e:GetVisualZDelta()
    return 128
end