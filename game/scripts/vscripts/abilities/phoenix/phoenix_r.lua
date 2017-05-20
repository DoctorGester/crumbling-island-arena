phoenix_r = class({})

LinkLuaModifier("modifier_phoenix_fly", "abilities/phoenix/modifier_phoenix_fly", LUA_MODIFIER_MOTION_NONE)

if IsClient() then
    require('heroes/hero_util')
end

PhoenixUtil.CastFitersLocation(phoenix_r)

function phoenix_r:GetChannelTime()
    return 6.0
end

function phoenix_r:GetChannelAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_2
end

if IsServer() then
    function phoenix_r:DestroyMarker()
        if self.marker then
            ParticleManager:DestroyParticle(self.marker, false)
            ParticleManager:ReleaseParticleIndex(self.marker)

            self.marker = nil
        end
    end

    function phoenix_r:DestroyBeam()
        if self.beam then
            ParticleManager:DestroyParticle(self.beam, false)
            ParticleManager:ReleaseParticleIndex(self.beam)

            self.beam = nil
        end
    end

    function phoenix_r:OnChannelThink(interval)
        local hero = self:GetCaster().hero
        local actualTarget = self:GetCursorPosition()
        local radius = 350

        local target = self.target or actualTarget

        local speed = 8

        if (target - actualTarget):Length2D() <= speed then
            target = actualTarget
        else
            target = target + (actualTarget - target):Normalized() * speed
        end

        self.target = target
        self.timePassed = self.timePassed or 0

        hero:SetFacing((self.target - hero:GetPos()) * Vector(1, 1, 0))

        if self.timePassed == 0 and not self.marker then
            self.marker = ParticleManager:CreateParticle("particles/phoenix_r/phoenix_r_marker.vpcf", PATTACH_ABSORIGIN, hero.unit)
            ParticleManager:SetParticleControl(self.marker, 1, Vector(radius, 0, 0))
            ParticleManager:SetParticleControl(self.marker, 2, Vector(radius, 0, 0))

            hero:EmitSound("Arena.Phoenix.CastR")
            hero:AddNewModifier(hero, nil, "modifier_phoenix_fly", { duration = 6 })
        end

        if self.marker then
            ParticleManager:SetParticleControl(self.marker, 0, target)
        end

        if self.timePassed ~= 0 then
            local up = self:GetChannelTime() / self.timePassed * 6 * interval

            hero:SetPos(hero:GetPos() + Vector(0, 0, up))
        end

        if self.timePassed > 0.5 then
            if not self.beam then
                self:DestroyMarker()

                hero:EmitSound("Arena.Phoenix.StartR", target)
                hero:EmitSound("Arena.Phoenix.LoopR")
                hero:EmitSound("Arena.Phoenix.LoopR2")

                self.beam = ParticleManager:CreateParticle("particles/phoenix_r/phoenix_r.vpcf", PATTACH_ABSORIGIN, hero.unit)
                ParticleManager:SetParticleControl(self.beam, 1, Vector(radius, 1, 1))
                ParticleManager:SetParticleControlEnt(self.beam, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetPos(), true)

                GridNav:DestroyTreesAroundPoint(target, radius, true)
            end

            ParticleManager:SetParticleControl(self.beam, 0, target)

            local damaged = self.damaged or {}
            self.damaged = damaged

            for entity, time in pairs(damaged) do
                damaged[entity] = time - interval
            end

            local function groupFilter(target)
                local time = damaged[target] or 0

                return time <= 0
            end

            hero:AreaEffect({
                filter = Filters.And(Filters.Area(target, radius), groupFilter),
                damage = true,
                action = function(target)
                    damaged[target] = 0.7
                end
            })
        end

        self.timePassed = self.timePassed + interval
    end

    function phoenix_r:OnChannelFinish(interrupted)
        local hero = self:GetCaster().hero
        local target = self:GetCursorPosition()

        self.target = nil
        
        hero:StopSound("Arena.Phoenix.LoopR")
        hero:StopSound("Arena.Phoenix.LoopR2")
        hero:EmitSound("Arena.Phoenix.EndR", target)
        hero:RemoveModifier("modifier_phoenix_fly")

        if self.timePassed and self.timePassed > 0.5 and not hero:FindModifier(EGG_MODIFIER) then
            hero:SetHealth(1)
            hero:Damage(self)
        end

        self.damaged = nil
        self.timePassed = nil
        self:DestroyMarker()
        self:DestroyBeam()

        hero:FindClearSpace(hero:GetPos(), true)
    end
end

if IsServer() then
    Wrappers.GuidedAbility(phoenix_r, true, true)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(phoenix_r)