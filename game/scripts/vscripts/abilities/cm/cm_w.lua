cm_w = class({})

function cm_w:GetChannelTime()
    return 2.0
end

function cm_w:OnChannelFinish(interrupted)
    self.timePassed = nil
    self.previousTarget = nil
end

function cm_w:OnChannelThink(interval)
    local hero = self:GetCaster():GetParentEntity()
    local target = self:GetCursorPosition() * Vector(1, 1, 0)

    self.previousTarget = self.previousTarget or target

    if (self.previousTarget - target):Length2D() > 30 then
        target = self.previousTarget + (target - self.previousTarget):Normalized() * 30
    end

    hero:SetFacing((target - hero:GetPos()) * Vector(1, 1, 0))

    self.previousTarget = target

    self.damaged = self.damaged or {}
    self.timePassed = (self.timePassed or 0) + interval

    if self.timePassed > 0.12 then
        hero:EmitSound("Arena.CM.PreW", target)

        self.projectileCounter = (self.projectileCounter or 0) + 1

        ArcProjectile(hero.round, {
            ability = self,
            owner = hero,
            from = target + Vector(0, 0, 1600) - hero:GetFacing() * 400,
            to = target,
            speed = 3000,
            arc = 200,
            radius = 96,
            graphics = "particles/cm_w/cm_w.vpcf",
            hitFunction = function(projectile, hit)
                local function groupFilter(target)
                    return not self.damaged[target]
                end

                local hit = hero:AreaEffect({
                    ability = self,
                    filter = Filters.And(Filters.Area(target, 128), groupFilter),
                    action = function(victim)
                        CMUtil.AbilityHit(hero, victim, self)
                        
                        self.damaged[victim] = true
                    end
                })

                ScreenShake(target, 3, 60, 0.15, 2000, 0, true)

                local sound = "Arena.CM.CastW"
                if hit then sound = "Arena.CM.HitW" end

                hero:EmitSound(sound, target)
                ImmediateEffectPoint("particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_arcana_ground_ambient.vpcf", PATTACH_CUSTOMORIGIN, hero, target)
            end,
            destroyFunction = function()
                self.projectileCounter = (self.projectileCounter or 0) - 1

                if self.projectileCounter == 0 then
                    self.damaged = nil
                end
            end
        }):Activate()

        self.timePassed = nil
    end
end

function cm_w:GetPlaybackRateOverride()
    return 0.4
end

function cm_w:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

if IsServer() then
    Wrappers.GuidedAbility(cm_w, true, true)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(cm_w)