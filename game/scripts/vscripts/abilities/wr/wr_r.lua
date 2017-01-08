wr_r = class({})
LinkLuaModifier("modifier_wr_r", "abilities/wr/modifier_wr_r", LUA_MODIFIER_MOTION_NONE)

function wr_r:OnChannelThink(interval)
    self.channelingTime = (self.channelingTime or 0) + interval

    local shots = self.shots or 0
    local hero = self:GetCaster():GetParentEntity()

    if self.channelingTime >= shots * 0.4 + 0.5 then
        local target = self:GetCursorPosition()
        hero:Animate(ACT_DOTA_ATTACK, 2.0)

        DistanceCappedProjectile(hero.round, {
            owner = hero,
            from = hero:GetPos() + Vector(0, 0, 128),
            to = target + Vector(0, 0, 128),
            speed = 3500,
            distance = 2000,
            graphics = "particles/wr_r/wr_r.vpcf",
            destroyFunction = function(projectile)
                projectile:AreaEffect({
                    filter = Filters.Area(projectile:GetPos(), 300),
                    damage = self:GetDamage(),
                    knockback = {
                        force = 80,
                        direction = function(v) return v:GetPos() - projectile:GetPos() end
                    }
                })

                ScreenShake(projectile:GetPos(), 5, 150, 0.25, 2000, 0, true)

                projectile:EmitSound("Arena.WR.HitR2")
            end,
            hitSound = "Arena.WR.HitQ"
        }):Activate()

        hero:EmitSound("Arena.WR.HitR")

        FX("particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_channel_ti6_shock_ring.vpcf", PATTACH_ABSORIGIN, hero, {
            cp1 = { ent = hero, attach = PATTACH_ABSORIGIN },
            release = true
        })

        ScreenShake(hero:GetPos(), 5, 150, 0.25, 3000, 0, true)

        self.shots = shots + 1
    end

    if interval == 0 then
        hero:EmitSound("Arena.WR.CastR.Voice")
        hero:EmitSound("Arena.WR.CastR")
        hero:AddNewModifier(hero, self, "modifier_wr_r", {})
        hero:Animate(ACT_DOTA_SPAWN, 2.0)
    end
end

function wr_r:OnChannelFinish()
    self.channelingTime = 0
    self.soundPlayed = false
    self.shots = 0

    local hero = self:GetCaster():GetParentEntity()
    hero:StopSound("Arena.WR.CastR")
    hero:RemoveModifier("modifier_wr_r")
end

function wr_r:GetChannelTime()
    return 2.0
end

--[[
function wr_r:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function wr_r:GetPlaybackRateOverride()
    return 1.0
end
]]--

if IsServer() then
    Wrappers.GuidedAbility(wr_r, true)
end