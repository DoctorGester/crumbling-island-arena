modifier_jugger_q = class({})

if IsServer() then
    function modifier_jugger_q:OnCreated()
        local hero = self:GetParent():GetParentEntity()
        local index = FX("particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {
            cp5 = Vector(350, 1, 1),
            release = false,
        })

        self:AddParticle(index, false, false, -1, false, false)
        self:StartIntervalThink(0.7)

        hero:EmitSound("Arena.Jugger.LoopQ")
    end

    function modifier_jugger_q:OnIntervalThink()
        local hero = self:GetParent():GetParentEntity()

        hero:AreaEffect({
            filter = Filters.Area(hero:GetPos(), 300),
            damage = self:GetAbility():GetDamage()
        })
    end

    function modifier_jugger_q:OnDestroy()
        local hero = self:GetParent():GetParentEntity()

        hero:StopSound("Arena.Jugger.LoopQ")
        hero:EmitSound("Arena.Jugger.EndQ")
    end
end

function modifier_jugger_q:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end

function modifier_jugger_q:CheckState()
    return {
        [MODIFIER_STATE_SILENCED] = true
    }
end

function modifier_jugger_q:GetOverrideAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_1
end