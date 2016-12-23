tiny_e = class({})

function tiny_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local radius = 250
    local duration = 4
    local delay = 0.75
    local mod = hero:FindModifier("modifier_tiny_r")

    if mod and not mod.used then
        delay = 0.0

        mod:Use()
    end

    CreateAOEMarker(hero, target, radius, delay, Vector(127, 106, 0))

    TimedEntity(delay,
        function()
            local particle = FX("particles/tiny_e/tiny_e.vpcf", PATTACH_ABSORIGIN, GameRules:GetGameModeEntity(), {
                cp0 = target,
                cp1 = Vector(radius, 1, 1),
                cp2 = Vector(duration, 0, 0),
                release = false
            })

            local obstructions = {}
            local amount = 16

            for i = 0, amount - 1 do
                local angle = math.rad(360 / amount * i)
                local offset = Vector(math.cos(angle), math.sin(angle), 0) * radius
                local pso = SpawnEntityFromTableSynchronous("point_simple_obstruction", {
                    origin = target + offset,
                })

                table.insert(obstructions, pso)
            end

            hero:EmitSound("Arena.Tiny.CastE", target)

            TimedEntity(duration,
                function()
                    for _, pso in ipairs(obstructions) do
                        pso:RemoveSelf()
                    end

                    ParticleManager:DestroyParticle(particle, false)
                    ParticleManager:ReleaseParticleIndex(particle)

                    hero:EmitSound("Arena.Tiny.EndE", target)
                end
            ):Activate()
        end
    ):Activate()
end

function tiny_e:GetCastAnimation()
    if self:GetCaster():HasModifier("modifier_tiny_r") then
        return ACT_DOTA_CAST_ABILITY_1
    end

    return ACT_TINY_AVALANCHE
end