shaker_r = class({})

function shaker_r:OnAbilityPhaseStart()
    self:GetCaster().hero:EmitSound("Arena.Shaker.PreQ")
    return true
end

function shaker_r:OnSpellStart()
    local hero = self:GetCaster().hero
    local effect = ImmediateEffect("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_egset.vpcf", PATTACH_ABSORIGIN, hero)
    ParticleManager:SetParticleControl(effect, 0, hero:GetPos())
    ParticleManager:SetParticleControl(effect, 1, Vector(3, 0, 0))

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local start = hero:GetPos()
    local len = 1200
    local speed = 60
    local currentLen = 0

    -- TODO add totem effect

    local pieces = {}
    local damaged = {}
    local offsets = {}

    hero:AddNewModifier(hero, hero:FindAbility("shaker_a"), "modifier_shaker_a", { duration = 5 })

    GameRules.GameMode.level:GroundAction(
        function(part)
            if (start - Vector(part.x, part.y, 0)):Length2D() > len then
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
                    local distance = (start - Vector(part.x, part.y, 0)):Length2D()

                    if distance > currentLen and distance <= currentLen + speed then
                        if part.health <= 50 then
                            GameRules.GameMode.level:LaunchPart(part, hero)
                        else 
                            offsets[part] = 7 + currentLen / len * RandomFloat(7, 25)

                            part.offsetZ = part.offsetZ + offsets[part]
                            GameRules.GameMode.level:UpdatePartPosition(part)
                        end
                    end

                    if distance < currentLen - speed * 6 and offsets[part] then
                        part.offsetZ = part.offsetZ - offsets[part]
                        offsets[part] = nil
                        GameRules.GameMode.level:UpdatePartPosition(part)
                    end

                    if distance > currentLen and distance < currentLen + speed * 4 then
                        working = true
                    end

                end
            end

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
                filter = Filters.Area(start, currentLen + speed) + -Filters.Area(start, currentLen) + groupFilter,
                modifier = { name = "modifier_stunned_lua", duration = 1.2, ability = self },
                action = function(target)
                    damaged[target] = true
                end
            })

            if currentLen ~= len then
                return 0.01
            else
                finish()
            end
        end
    )

    hero:EmitSound("Arena.Shaker.CastR")
    hero:EmitSound("Arena.Shaker.CastR2")
end

function shaker_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function shaker_r:GetPlaybackRateOverride()
    return 1.2
end