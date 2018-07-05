EntityTinkerR = EntityTinkerR or class({}, nil, UnitEntity)

function EntityTinkerR:constructor(round, owner, position, ability)
    getbase(EntityTinkerR).constructor(self, round, "tinker_cog", position, owner:GetUnit():GetTeamNumber(), true)

    self.hero = owner
    self.owner = owner.owner
    self.collisionType = COLLISION_TYPE_RECEIVER
    self.removeOnDeath = false
    self.startTime = GameRules:GetGameTime()
    self.ability = ability
    self.ignoreGroup = {}

    self:AddNewModifier(owner.unit, ability, "modifier_tinker_r", {})
    self:EmitSound("Arena.Sniper.CastW")
    self:AddComponent(HealthComponent())
    self:SetCustomHealth(3)
    self:EnableHealthBar()
end

function EntityTinkerR:Update()
    getbase(EntityTinkerR).Update(self)

    if self.falling then
        return
    end

    local time = GameRules:GetGameTime()

    self.hero:AreaEffect({
        ability = self.ability,
        targetProjectiles = true,
        sound = "Arena.Tinker.HitR",
        filter = Filters.Area(self:GetPos(), 400) + Filters.WrapFilter(
            function(target)
                return time - (self.ignoreGroup[target] or 0) >= 1 and not instanceof(target, Obstacle)
            end
        ),
        action = function(target)
            local normal = (target:GetPos() - self:GetPos()):Normalized()

            if instanceof(target, Projectile) then
                local velocity = target.vel
                local reflectedDirection = velocity - 2 * (velocity:Dot(normal)) * normal;
                target:Deflect(self, reflectedDirection)
            else
                self.round.spells:InterruptDashes(target)
                SoftKnockback(target, self, normal, 50, { decrease = 3 })
                target:Damage(self, self.ability:GetDamage())
            end
        end,
        notBlockedAction = function(target)
            FX("particles/units/heroes/hero_rattletrap/rattletrap_cog_attack.vpcf", PATTACH_ABSORIGIN, self, {
                cp0 = { ent = self, point = "attach_attack1" },
                cp1 = target:GetPos() + Vector(0, 0, 64),
                release = true
            })

            self.ignoreGroup[target] = time
        end
    })

    -- Reflecting arc projectiles
    local arcProjectiles = self.round.spells:FilterEntities(function(ent)
        return instanceof(ent, ArcProjectile) and ent:Alive() and not ent.falling
    end)

    for _, arcProjectile in pairs(arcProjectiles) do
        local towardsProjectile = arcProjectile:GetPos() - self:GetPos()

        if towardsProjectile:Length() <= 400.0 and arcProjectile.owner.team ~= self.owner.team  then
            arcProjectile:Destroy()

            FX("particles/units/heroes/hero_rattletrap/rattletrap_cog_attack.vpcf", PATTACH_ABSORIGIN, self, {
                cp0 = { ent = self, point = "attach_attack1" },
                cp1 = arcProjectile:GetPos(),
                release = true
            })

            self:EmitSound("Arena.Tinker.HitR")

            if arcProjectile.hitSound then
                arcProjectile:EmitSound(arcProjectile.hitSound)
            end
        end
    end

    if GameRules:GetGameTime() - (self.startTime or 0) > 6 then
        self:Destroy()
    end
end