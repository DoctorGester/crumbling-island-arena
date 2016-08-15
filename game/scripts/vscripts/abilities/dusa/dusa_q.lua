dusa_q = class({})
local self = dusa_q

function self:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1600)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local launches = 0

    local hitGroup = {}
    local function groupFilter(target)
        return not hitGroup[target]
    end

    Timers:CreateTimer(function()
        if not IsValidEntity(self:GetCaster()) then
            return
        end

        for i = 0, 4 do
            ArcProjectile(self.round, {
                owner = hero,
                from = hero:GetPos() + Vector(0, 0, 128),
                to = target + RandomVector(1) * RandomFloat(0, 200),
                speed = 2000,
                arc = 700,
                graphics = "particles/dusa_q/dusa_q.vpcf",
                hitParams = {
                    filter = Filters.Area(target, 250) + Filters.WrapFilter(groupFilter),
                    filterProjectiles = true,
                    damage = true
                },
                hitFunction = function(projectile, hit)
                    if hit then
                        for _, victim in pairs(hit) do
                            hitGroup[victim] = true
                        end
                    end
                end,
                hitSound = "Arena.Medusa.HitQ",
                disableStats = true
            }):Activate()
        end

        launches = launches + 1

        if launches == 4 then
            return
        end

        return 0.03
    end)

    hero.round.statistics:IncreaseProjectilesFired(hero.owner)

    CreateAOEMarker(hero, self:GetCursorPosition(), 250, 1.0, Vector(106, 190, 0))
    hero:EmitSound("Arena.Medusa.CastQ")

    self.tick = (self.tick or 0) + 1

    if self.tick % 2 == 0 then
        hero:EmitSound("Arena.Medusa.CastQ.Voice")
    end
end

function self:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

function self:GetPlaybackRateOverride()
    return 2.0
end