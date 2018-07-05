cm_e = class({})

LinkLuaModifier("modifier_cm_e", "abilities/cm/modifier_cm_e", LUA_MODIFIER_MOTION_NONE)

function cm_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1100)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local icePath = DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos(),
        to = target,
        speed = 700,
        graphics = "particles/cm/cm_e.vpcf",
        distance = 1100,
        continueOnHit = true,
        damagesTrees = true,
        goesThroughTrees = true,
        hitFunction = function(_, target)
            CMUtil.AbilityHit(hero, target, self)

            target:EmitSound("Arena.CM.HitE")
        end,
        destroyFunction = function(projectile)
            hero:StopSound("Arena.CM.LoopE")
            hero:SwapAbilities("cm_e_sub", "cm_e")
            hero:RemoveModifier("modifier_cm_e")

            self.icePath = nil
        end
    }):Activate()

    self.icePath = icePath

    hero:EmitSound("Arena.CM.CastE")
    hero:EmitSound("Arena.CM.LoopE")
    hero:SwapAbilities("cm_e", "cm_e_sub")
    hero:FindAbility("cm_e_sub"):StartCooldown(0.3)
    hero:AddNewModifier(hero, hero:FindAbility("cm_e_sub"), "modifier_cm_e", {})
end

function cm_e:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(cm_e)