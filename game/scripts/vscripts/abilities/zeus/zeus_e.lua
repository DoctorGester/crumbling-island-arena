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

    if hero:WallIntersection(casterPos, target) then
        hero:AreaEffect({
            filter = Filters.Line(casterPos, target, 64),
            filterProjectiles = true,
            sound = "Arena.TA.HitQ",
            damage = true,
            action = function(target)
                local pos = target:GetPos()
                self:CreateLightning(self, pos + Vector(0, 0, 800), pos)
            end
        })
    end

    self:CreateLightning(self, Vector(casterPos.x, casterPos.y, casterPos.z + 64), Vector(target.x, target.y, target.z + 64))
    hero:EmitSound("Arena.Zeus.CastE")
end

function zeus_e:GetCastAnimation()
    return ACT_DOTA_TELEPORT_END
end