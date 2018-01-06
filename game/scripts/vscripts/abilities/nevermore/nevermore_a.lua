nevermore_a = class({})

LinkLuaModifier("modifier_nevermore_a", "abilities/nevermore/modifier_nevermore_a", LUA_MODIFIER_MOTION_NONE)

function nevermore_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 750, 750)

    local hero = self:GetCaster():GetParentEntity()
    local target = self:GetCursorPosition()
    local dir = self:GetDirection()
    dir = Vector(dir.y, -dir.x)

    local damageMultiplier = 1
    local stacks = self:GetCaster():GetModifierStackCount("modifier_nevermore_a", self:GetCaster())

    if stacks >= 8 then
        damageMultiplier = 2
    end

    if stacks >= 16 then
        damageMultiplier = 3
    end

    DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 96) + dir * 80,
        to = target + Vector(0, 0, 96),
        damage = self:GetDamage() * damageMultiplier,
        speed = 1450,
        radius = 64,
        graphics = "particles/nevermore_a/nevermore_a.vpcf",
        distance = 750,
        hitSound = "Arena.Nevermore.HitA",
        screenShake = { 5, 150, 0.15, 3000, 0, true },
        isPhysical = true,
        hitFunction = function(projectile, target)
            target:Damage(projectile, projectile.damage, true)

            local trueHero = projectile:GetTrueHero()

            if instanceof(target, Hero) and trueHero:FindAbility("nevermore_a") then
                local stackingModifier = trueHero:FindModifier("modifier_nevermore_a")

                if not stackingModifier then
                    stackingModifier = trueHero:AddNewModifier(trueHero, self, "modifier_nevermore_a", {})
                end

                if stackingModifier and stackingModifier:GetStackCount() < 16 then
                    stackingModifier:IncrementStackCount()

                    local path = "particles/nevermore_a/nevermore_a_souls.vpcf"
                    FX(path, PATTACH_CUSTOMORIGIN_FOLLOW, GameRules:GetGameModeEntity(), {
                        cp0 = { ent = target, point = "attach_hitloc" },
                        cp1 = { ent = trueHero, point = "attach_hitloc" },
                        release = true
                    })
                end
            end
        end
    }):Activate()

    hero:EmitSound("Arena.Nevermore.CastA")
end

function nevermore_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function nevermore_a:GetPlaybackRateOverride()
    return 3.5
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(nevermore_a)