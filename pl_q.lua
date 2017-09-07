pl_q = class({})

local self = pl_q

function pl_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 900)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = self:GetDirection()

    DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1313, -- keepo
        graphics = "particles/pl_projectile/pl_projectile.vpcf",
        distance = 3000,
        hitSound = "Arena.PL.HitQ",
        damagesTrees = true,
        hitFunction = function(projectile, target)           
            target:Damage(hero, self:GetDamage())
            --target:FindClearSpace(target:GetPos() + direction * 180, true)
            --target:SetFacing(-direction)
            EntityPLIllusion(hero.round, hero, target:GetPos() + direction * 180, -self:GetDirection(), self):Activate():SetTarget(hero)

            FX("particles/units/heroes/hero_phantom_lancer/phantomlancer_spiritlance_flash_target.vpcf", PATTACH_WORLDORIGIN, target, {
                cp0 = target:GetPos() + Vector(0, 0, 64),
                release = true
            })
        end
    }):Activate()

    hero:EmitSound("Arena.PL.CastQ")
end

function pl_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function pl_q:GetPlaybackRateOverride()
    return 2.0
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(pl_q)