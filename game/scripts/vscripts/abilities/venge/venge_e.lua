venge_e = class({})

function venge_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()
    local ability = self

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    Projectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1300,
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

            hero:FindClearSpace(target:GetPos(), false)

            if target.FindClearSpace then
                target:FindClearSpace(pos, false)
            else
                target:SetPos(pos)
            end
            
            target:EmitSound("Arena.Venge.HitE")
        end,
        hitCondition = function(projectile, target)
            return target ~= hero
        end
    }):Activate()

    hero:EmitSound("Arena.Venge.CastE")
end

function venge_e:GetCastAnimation()
    return ACT_DOTA_ATTACK
end
