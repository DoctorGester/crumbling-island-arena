venge_q = class({})

function venge_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local trueHero = hero.hero or hero
    local ability = trueHero:FindAbility("venge_q")
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        ability = ability,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1250,
        graphics = "particles/venge_q/venge_q.vpcf",
        distance = 950,
        damagesTrees = true,
        hitSound = "Arena.Venge.HitQ",
        hitFunction = function(projectile,target) 
            target:Damage(trueHero, ability:GetDamage())
            target:AddNewModifier(trueHero, ability, "modifier_stunned_lua", { duration = 0.85 })
        end
    }):Activate()

    hero:EmitSound("Arena.Venge.CastQ")
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(venge_q)
