modifier_ursa_frenzy = class({})

if IsServer() then
    function modifier_ursa_frenzy:OnCreated()
        local hero = self:GetParent():GetParentEntity()
        hero:FindAbility("ursa_q"):EndCooldown()
        hero:EmitSound("Arena.Ursa.Frenzy")
        hero:Animate(ACT_DOTA_OVERRIDE_ABILITY_3)

        local index = FX("particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, {
            cp0 = { ent = hero, point = "attach_head" },
            cp2 = { ent = hero, point = "attach_hitloc" },
            cp3 = { ent = hero, point = "attach_hitloc" },
            release = false
        })

        self:AddParticle(index, false, false, -1, false, false)
    end

    function modifier_ursa_frenzy:OnDestroy()
        local hero = self:GetParent():GetParentEntity()

        hero:AddNewModifier(hero, hero:FindAbility("ursa_a"), "modifier_ursa_fury", {})
    end
end

function modifier_ursa_frenzy:StatusEffectPriority()
    return 2
end

function modifier_ursa_frenzy:GetStatusEffectName()
    return "particles/status_fx/status_effect_overpower.vpcf"
end