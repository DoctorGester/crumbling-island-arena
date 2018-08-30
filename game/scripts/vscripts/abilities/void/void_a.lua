void_a = class({})

function void_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero

    hero:EmitSound("Arena.Void.CastA")

    return true
end

function void_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local range = 300
    local damage = self:GetDamage()
    local recharge = nil

    hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, range, forward, math.pi),
        sound = "Arena.Void.HitA",
        damagesTrees = true,
        damage = damage,
        action = function(target)
            if instanceof(target, Hero) then
                recharge = true
            end
        end,
        knockback = { force = 20, decrease = 3 },
        isPhysical = true
    })

    if recharge == true then
        local atLeastOneAbilityCDReduced = nil
        for i = 0, self:GetCaster():GetAbilityCount() - 1 do
            local ability1 = self:GetCaster():GetAbilityByIndex(i)

            if ability1 and ability1:IsActivated() and not ability1:IsAttributeBonus() and not ability1:IsCooldownReady() and not IsAttackAbility(ability1) then
                local timeleft = ability1:GetCooldownTimeRemaining()
                if (timeleft - 1.5) < 0 then
                    timeleft = 1.5
                end
                ability1:EndCooldown()
                ability1:StartCooldown(timeleft - 1.5)

                atLeastOneAbilityCDReduced = true
            end
        end

        if atLeastOneAbilityCDReduced == true then
            FX(hero:GetMappedParticle("particles/econ/items/wisp/wisp_guardian_explosion_ti7.vpcf"), PATTACH_POINT_FOLLOW, hero, {
                cp0 = { ent = self:GetCaster() },
                release = true
            })
            hero:EmitSound("Arena.Void.ProcA")
            Timers:CreateTimer(0.5, function()
                hero:StopSound("Arena.Void.ProcA")
            end)
        end
    end
end

function void_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function void_a:GetPlaybackRateOverride()
    return 2.5
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(void_a, nil, "particles/melee_attack_blur.vpcf")
