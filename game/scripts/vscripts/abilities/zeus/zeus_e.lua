zeus_e = class({})

function zeus_e:CreateLightning(self, from, to)
    local particlePath = "particles/units/heroes/hero_razor/razor_storm_lightning_strike.vpcf"
    local particle = ImmediateEffect(particlePath, PATTACH_CUSTOMORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, from)
    ParticleManager:SetParticleControl(particle, 1, to)
end

function zeus_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 600)

    local hero = self:GetCaster().hero
    local casterPos = hero:GetPos()
    local target = self:GetCursorPosition()

    GridNav:DestroyTreesAroundPoint(target, 128, true)
    hero:FindClearSpace(target, true)

    for _, wall in pairs(hero.round.spells:FilterEntities(function(t)
        return instanceof(t, EntityZeusW) and t.owner.team == hero.owner.team and t:IntersectsWith(casterPos, target)
    end)) do
        hero:AreaEffect({
            ability = self,
            filter = Filters.Line(casterPos, target, 64),
            filterProjectiles = true,
            damage = self:GetDamage(),
            sound = "Arena.Zeus.HitE",
            action = function(target)
                local pos = target:GetPos()
                self:CreateLightning(self, pos + Vector(0, 0, 800), pos)

                ZeusUtil.AbilityHit(hero, self, target)
            end
        })

        break
    end

    self:CreateLightning(self, Vector(casterPos.x, casterPos.y, casterPos.z + 64), Vector(target.x, target.y, target.z + 64))
    hero:EmitSound("Arena.Zeus.CastE")
end

function zeus_e:GetCastAnimation()
    return ACT_DOTA_TELEPORT_END
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(zeus_e)