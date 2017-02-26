modifier_invoker_e = class({})

if IsServer() then
    function modifier_invoker_e:OnCreated(kv)
        self:GetParent():EmitSound("Arena.Invoker.CastE")
        self:GetParent():EmitSound("Arena.Invoker.LoopE")

        self:StartIntervalThink(0.35)
    end

    function modifier_invoker_e:OnIntervalThink()
        self:StartIntervalThink(-1)

        if self.destroyed then
            return
        end

        local particle = FX("particles/aoe_marker_filled_thin.vpcf", PATTACH_ABSORIGIN, self:GetParent(), {
            cp0 = self:GetParent():GetAbsOrigin(),
            cp1 = Vector(400, 1, 1),
            cp2 = Vector(195, 143, 200),
            cp3 = Vector(0.5, 0, 0)
        })

        self:AddParticle(particle, false, false, 0, true, false)
    end

    function modifier_invoker_e:OnAbilityImmediate(event)
        self:OnAbilityStart(event)
    end

    function modifier_invoker_e:OnAbilityStart(event)
        local hero = event.unit.hero

        if not event.ability.canBeSilenced or self:GetElapsedTime() < 0.35 then
            return
        end

        if hero and hero:FindModifier("modifier_invoker_e_target", self:GetCaster()) then
            if not self.destroyed then
                self:GoBang()
            end

            self:Destroy()
        end
    end

    function modifier_invoker_e:GoBang()
        local parent = self:GetParent()

        parent.hero:AreaEffect({
            ability = self:GetAbility(),
            filter = Filters.Area(parent:GetAbsOrigin(), 400),
            filterProjectiles = true,
            onlyHeroes = true,
            damage = self:GetAbility():GetDamage(),
            modifier = {
                name = "modifier_silence_lua",
                duration = 2.0,
                ability = self:GetAbility()
            }
        })

        self:GetParent():StopSound("Arena.Invoker.LoopE")
        self:GetParent():EmitSound("Arena.Invoker.EndE")

        self.destroyed = true
    end

    function modifier_invoker_e:OnDestroy()
        if not self.destroyed then
            self:GoBang()
        end
    end
end

function modifier_invoker_e:IsAura()
    return true
end

function modifier_invoker_e:GetAuraRadius()
    return 400
end

function modifier_invoker_e:GetAuraDuration()
    return 0.1
end

function modifier_invoker_e:GetModifierAura()
    return "modifier_invoker_e_target"
end

function modifier_invoker_e:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_invoker_e:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_invoker_e:GetAuraEntityReject()
    return self:GetElapsedTime() < 0.35
end

function modifier_invoker_e:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_VISUAL_Z_DELTA,
        MODIFIER_EVENT_ON_ABILITY_START
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