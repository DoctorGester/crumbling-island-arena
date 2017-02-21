shaker_q = class({})

function shaker_q:OnAbilityPhaseStart()
    self:GetCaster().hero:EmitSound("Arena.Shaker.PreQ")
    return true
end

function shaker_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1200, 1200)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = self:GetDirection()
    local start = hero:GetPos() + direction * 64
    local len = 1200
    local speed = 30
    local currentLen = 0
    local tick = 0

    -- TODO add totem effect

    local pieces = {}
    local damaged = {}
    local offsets = {}

    hero:AddNewModifier(hero, hero:FindAbility("shaker_a"), "modifier_shaker_a", { duration = 5 })

    GameRules.GameMode.level:GroundAction(
        function(part)
            local closest = ClosestPointToSegment(start, target, Vector(part.x, part.y, 0))
            local currentLen = (closest - start):Length2D()
            local closestLen = (closest - Vector(part.x, part.y, 0)):Length2D()

            if currentLen == 0 or currentLen == len or closestLen >= 150 then
                return
            end

            table.insert(pieces, part)
        end
    )

    local function finish()
        Timers:CreateTimer(0.05,
            function()
                for _, part in ipairs(pieces) do
                    if offsets[part] then
                        part.offsetZ = part.offsetZ - offsets[part]
                        GameRules.GameMode.level:UpdatePartPosition(part)
                    end
                end
            end
        )
    end

    Timers:CreateTimer(
        function()
            currentLen = math.min(currentLen + speed, len)

            local working = false

            for _, part in ipairs(pieces) do
                if not part.launched then
                    local closest = ClosestPointToSegment(start, target, Vector(part.x, part.y, 0))
                    local distance = (start - closest):Length2D()

                    if distance > currentLen and distance <= currentLen + speed then
                        offsets[part] = 15 + currentLen / len * 15

                        part.offsetZ = part.offsetZ + offsets[part]
                        GameRules.GameMode.level:UpdatePartPosition(part)
                    end

                    if distance < currentLen - 350 and offsets[part] then
                        part.offsetZ = part.offsetZ - offsets[part]
                        offsets[part] = nil
                        GameRules.GameMode.level:UpdatePartPosition(part)
                    end

                    if distance > currentLen and distance < currentLen + 500 then
                        working = true
                    end
                end
            end

            if tick % 5 == 0 then
                hero:EmitSound("Arena.Shaker.HitQ")
            end

            if tick % 4 == 0 then
                local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_healing_ward_eruption_dust.vpcf", PATTACH_WORLDORIGIN, hero:GetUnit())
                ParticleManager:SetParticleControl(particle, 0, start + direction * currentLen)
            end

            tick = tick + 1

            if not working then
                finish()
                return
            end

            local groupFilter = Filters.WrapFilter(
                function(target)
                    return damaged[target] == nil
                end
            )

            local hurt = hero:AreaEffect({
                ability = self,
                filter = Filters.Line(start + direction * (currentLen - speed), start + direction * currentLen, 100) + groupFilter,
                sound = "Arena.Shaker.HitQ2",
                damage = self:GetDamage(),
                filterProjectiles = true,
                action = function(target)
                    damaged[target] = true

                    Knockback(target, self, direction, 350, 1500, DashParabola(250))
                end
            })

            if currentLen ~= len then
                return 0.01
            else
                finish()
            end
        end
    )

    ScreenShake(start, 5, 150, 0.45, 3000, 0, true)
    hero:EmitSound("Arena.Shaker.CastQ")
end

function shaker_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function shaker_q:GetPlaybackRateOverride()
    return 2.5
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(shaker_q)