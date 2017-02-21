pudge_w = class({})

function pudge_w:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local direction = self:GetDirection()

    ScreenShake(pos, 5, 150, 0.45, 3000, 0, true)

    hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, 300, direction, math.pi),
        sound = "Arena.Pudge.HitW",
        damage = self:GetDamage(),
        action = function(target)
            local effectPos = target:GetPos() + Vector(0, 0, 64)
            local direction = (pos - effectPos):Normalized()
            local blood = ImmediateEffect("particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
            ParticleManager:SetParticleControlEnt(blood, 0, target.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", effectPos, true)
            ParticleManager:SetParticleControl(blood, 2, direction)

            if instanceof(target, Hero) and target:HasModifier("modifier_pudge_a") then
                local meatDir = (target:GetPos() - hero:GetPos()):Normalized()
                local meat = PudgeMeat(hero.round, hero, target:GetPos() + meatDir * 128):Activate()

                Knockback(meat, self, meatDir, 400, 1500, DashParabola(250))
            end
        end
    })

    local times = 0
    Timers:CreateTimer(0, function()
        hero:EmitSound("Arena.Pudge.CastW")

        if times == 2 then
            return
        end

        times = times + 1

        return 0.2
    end)
end

function pudge_w:GetCastAnimation()
    return ACT_DOTA_CHANNEL_ABILITY_4
end

function pudge_w:GetPlaybackRateOverride()
    return 3
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(pudge_w)