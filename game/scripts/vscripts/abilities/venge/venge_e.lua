venge_e = class({})

function venge_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1400,
        graphics = "particles/venge_e/venge_e.vpcf",
        distance = 950,
        hitSound = "Arena.Venge.HitE",
        hitFunction = function(projectile, target)
            local pos = hero:GetPos()

            local effect = ImmediateEffect("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN, hero)
            ParticleManager:SetParticleControl(effect, 0, hero:GetPos())
            ParticleManager:SetParticleControl(effect, 1, target:GetPos())

            effect = ImmediateEffect("particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_ABSORIGIN, hero)
            ParticleManager:SetParticleControl(effect, 1, hero:GetPos())
            ParticleManager:SetParticleControl(effect, 0, target:GetPos())

            local z = pos.z
            local heroPos = target:GetPos()
            pos.z = heroPos.z
            heroPos.z = z

            hero:FindClearSpace(heroPos, true)
            target:FindClearSpace(pos, true)
            
            target:EmitSound("Arena.Venge.HitE")

            hero.round.spells:InterruptDashes(hero)
            target.round.spells:InterruptDashes(target)

            -- Otherwise it gets destroyed anyway
            if instanceof(target, Projectile) then
                projectile:Destroy()
            end
        end,
        hitCondition = function(projectile, target)
            return target ~= hero
        end,
        hitProjectiles = true
    }):Activate()

    hero:EmitSound("Arena.Venge.CastE")
end

function venge_e:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function venge_e:GetPlaybackRateOverride()
    return 2.0
end
