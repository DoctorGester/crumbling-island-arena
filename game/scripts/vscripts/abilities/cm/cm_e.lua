cm_e = class({})

function cm_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1100)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local icePath = DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos(),
        to = target,
        speed = 700,
        graphics = "particles/cm/cm_e.vpcf",
        distance = 1100,
        continueOnHit = true,
        hitFunction = function(projectile, target)
            if hero:IsFrozen(target) then
                target:Damage(hero)
            else
                hero:Freeze(target, self)
            end

            target:EmitSound("Arena.CM.HitE")
        end,
        destroyFunction = function(projectile)
            hero:StopSound("Arena.CM.LoopE")
            hero:SwapAbilities("cm_e_sub", "cm_e")
            hero:SetIcePath(nil)
        end
    }):Activate()

    hero:SetIcePath(icePath)
    hero:EmitSound("Arena.CM.CastE")
    hero:EmitSound("Arena.CM.LoopE")
    hero:SwapAbilities("cm_e", "cm_e_sub")
    hero:FindAbility("cm_e_sub"):StartCooldown(0.3)
end

function cm_e:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end