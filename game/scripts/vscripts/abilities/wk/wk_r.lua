wk_r = class({})

function wk_r:OnAbilityPhaseStart()
    Wrappers.GuidedAbility(self, true)

    self:GetCaster().hero:EmitSound("Arena.WK.PreR")

    if RandomInt(1, 100) == 1 then
        self:GetCaster().hero:EmitSound("Arena.WK.CastR.Voice.Rare")
    else
        self:GetCaster().hero:EmitSound("Arena.WK.CastR.Voice")
    end

    return true
end

function wk_r:OnChannelThink(interval)
    self.speed = (self.speed or 2000) - 300

    local hero = self:GetCaster().hero
    local pos = hero:GetPos() + interval * Vector(0, 0, self.speed)
    pos.z = math.max(pos.z, 0)
    hero:SetPos(pos)
end

function wk_r:OnChannelFinish(interrupted)
    self.speed = nil

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:SetPos(hero:GetPos() * Vector(1, 1, 0))

    if interrupted then
        hero:StopSound("Arena.WK.PreR")
        return
    end

    local direction = target - hero:GetPos()

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    direction = direction:Normalized()

    local casterPos = hero:GetPos()
    local target = casterPos + direction:Normalized() * 2500
    local len = (target - casterPos):Length2D()
    local start = hero:GetPos() + direction:Normalized() * 64

    local currentLen = 128
    local previousPoint = casterPos

    while (currentLen < len) do
        local point = start + direction * currentLen

        if not Spells.TestPoint(point) then
            target = previousPoint
            break
        end

        previousPoint = point
        currentLen = currentLen + 64
    end

    local len = (target - start):Length2D()

    local effect = ImmediateEffect("particles/wk_r/wk_r.vpcf", PATTACH_ABSORIGIN, hero)
    ParticleManager:SetParticleControl(effect, 0, hero:GetPos() + direction:Normalized() * 64)
    ParticleManager:SetParticleControl(effect, 1, target)

    local hurt = hero:AreaEffect({
        filter = Filters.Line(hero:GetPos(), target, 128),
        sound = "Arena.WK.HitR",
        damage = 1,
        modifier = { name = "modifier_stunned_lua", duration = 1.5, ability = self }
    })

    ScreenShake(casterPos, 5, 150, 0.45, 4000, 0, true)

    GameRules.GameMode.level:GroundAction(
        function(part)
            local isLeft = IsLeft(start, target, Vector(part.x, part.y, 0))
            local leftDir = Vector(direction.y, -direction.x)
            local closest = ClosestPointToSegment(start, target, Vector(part.x, part.y, 0))

            local currentLen = (closest - start):Length2D()
            local closestLen = (closest - Vector(part.x, part.y, 0)):Length2D()

            if currentLen == 0 or currentLen == len or closestLen >= 256 then
                return
            end

            local offset = leftDir * (32 * (currentLen / len))

            if isLeft then
                offset = -offset
            end

            GameRules.GameMode.level:SetPartOffset(part, part.offsetX + offset.x, part.offsetY + offset.y)
        end
    )

    hero:EmitSound("Arena.WK.CastR")
end

function wk_r:GetChannelTime()
    return 0.5
end

function wk_r:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

function wk_r:GetPlaybackRateOverride()
    return 1.2
end