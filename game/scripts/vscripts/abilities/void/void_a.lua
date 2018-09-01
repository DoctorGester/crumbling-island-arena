void_a = class({})

function void_a:OnAbilityPhaseStart()
    self:GetCaster():GetParentEntity():EmitSound("Arena.Void.CastA")

    return true
end

function void_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster():GetParentEntity()
    local range = 300
    local cooldownReduction = 1.5

    local hitAnyone = hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(hero:GetPos(), range, self:GetDirection(), math.pi),
        sound = "Arena.Void.HitA",
        damagesTrees = true,
        damage = self:GetDamage(),
        knockback = { force = 20, decrease = 3 },
        isPhysical = true
    })

    if hitAnyone then
        local atLeastOneCooldownReduced

        for index = 0, self:GetCaster():GetAbilityCount() - 1 do
            local ability = self:GetCaster():GetAbilityByIndex(index)
            local abilityShouldBeReduced = ability and ability:IsActivated() and
                    not ability:IsAttributeBonus() and
                    not ability:IsCooldownReady() and
                    not IsAttackAbility(ability)

            if abilityShouldBeReduced then
                local newCooldown = math.max(ability:GetCooldownTimeRemaining() - cooldownReduction, 0)

                ability:EndCooldown()

                if newCooldown > 0 then
                    ability:StartCooldown(newCooldown)
                end

                atLeastOneCooldownReduced = true
            end
        end

        if atLeastOneCooldownReduced then
            FX(hero:GetMappedParticle("particles/econ/items/wisp/wisp_guardian_explosion_ti7.vpcf"), PATTACH_POINT_FOLLOW, hero, {
                cp0 = { ent = hero },
                release = true
            })

            hero:EmitSound("Arena.Void.ProcA")

            TimedEntity(0.5, function()
                hero:StopSound("Arena.Void.ProcA")
            end):Activate()
        end
    end
end

function void_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function void_a:GetPlaybackRateOverride()
    return 3.0
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(void_a, nil, "particles/melee_attack_blur.vpcf")
