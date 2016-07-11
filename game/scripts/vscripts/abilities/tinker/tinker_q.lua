tinker_q = class({})

function tinker_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 700, 700)

    local hero = self:GetCaster().hero
    local facing = hero:GetFacing()
    local from = hero:GetPos() + Vector(facing.y, -facing.x, 0) * 96
    local target = self:GetCursorPosition()
    local height = Vector(0, 0, 200)

    local interPortal = hero:GetFirstPortal()
    local nextPortal = hero:GetSecondPortal()
    local intersection = false

    if interPortal and nextPortal then
        intersection = self:GetPortalIntersection(hero:GetFirstPortal(), from, target)

        if intersection then
            local secondIntersection = self:GetPortalIntersection(hero:GetSecondPortal(), from, target)

            if secondIntersection and (intersection - from):Length2D() > (secondIntersection - from):Length2D() then
                intersection = nil
            end
        end

        if not intersection then
            intersection = self:GetPortalIntersection(hero:GetSecondPortal(), from, target)
            nextPortal = hero:GetFirstPortal()
            interPortal = hero:GetSecondPortal()
        end
    end

    if intersection then
        local effect = ImmediateEffect("particles/units/heroes/hero_tinker/tinker_laser.vpcf", PATTACH_ABSORIGIN, hero)
        ParticleManager:SetParticleControlEnt(effect, 9, hero:GetUnit(), PATTACH_POINT_FOLLOW, "ArbitraryChain8_plc8", hero:GetPos(), true)
        ParticleManager:SetParticleControl(effect, 1, intersection + height)

        local diff = interPortal:GetPos() - intersection
        local portalStart = nextPortal:GetPos() + diff
        local remaining = 700 - (intersection - from):Length2D()
        local dir = (intersection - from):Normalized()
        local portalEnd = portalStart + remaining * dir

        effect = ImmediateEffect("particles/units/heroes/hero_tinker/tinker_laser.vpcf", PATTACH_ABSORIGIN, hero)
        ParticleManager:SetParticleControl(effect, 9, portalStart + height / 2)
        ParticleManager:SetParticleControl(effect, 1, portalEnd + height / 2)

        hero:AreaEffect({
            filter = Filters.Line(from, intersection, 64),
            damage = true,
            sound = "Arena.Tinker.HitQ"
        })

        hero:AreaEffect({
            filter = Filters.Line(portalStart, portalEnd, 64),
            damage = true,
            sound = "Arena.Tinker.HitQ"
        })
    else
        local effect = ImmediateEffect("particles/units/heroes/hero_tinker/tinker_laser.vpcf", PATTACH_ABSORIGIN, hero)
        ParticleManager:SetParticleControlEnt(effect, 9, hero:GetUnit(), PATTACH_POINT_FOLLOW, "ArbitraryChain8_plc8", hero:GetPos(), true)
        ParticleManager:SetParticleControl(effect, 1, target)

        hero:AreaEffect({
            filter = Filters.Line(from, target, 64),
            damage = true,
            sound = "Arena.Tinker.HitQ"
        })
    end

    hero:EmitSound("Arena.Tinker.CastQ")
end

function tinker_q:GetPortalIntersection(portal, from, to)
    if not portal then
        return false
    end

    local closest = ClosestPointToSegment(from, to, portal:GetPos())
    local dist = portal:GetPos() - closest

    if dist:Length2D() <= portal.size + 96 then
        return closest
    end
end

function tinker_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function tinker_q:GetPlaybackRateOverride()
    return 1.33
end