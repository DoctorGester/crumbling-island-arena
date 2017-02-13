EntityTinkerR = EntityTinkerR or class({}, nil, BreakableEntity)

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
    self:AddNewModifier(self, nil, "modifier_custom_healthbar", {})
    self:EmitSound("Arena.Sniper.CastW")
    self:SetCustomHealth(3)
    self:EnableHealthBar()
end

function EntityTinkerR:Update()
    getbase(EntityTinkerR).Update(self)

    local time = GameRules:GetGameTime()

    self.hero:AreaEffect({
        ability = self.ability,
        targetProjectiles = true,
        sound = "Arena.Tinker.HitR",
        filter = Filters.Area(self:GetPos(), 400) + Filters.WrapFilter(
            function(target)
                return time - (self.ignoreGroup[target] or 0) >= 1
            end
        ),
        action = function(target)
            local dir = target:GetPos() - self:GetPos()

            if instanceof(target, Projectile) then
                target:Deflect(self, dir)
            else
                self.round.spells:InterruptDashes(target)
                SoftKnockback(target, self, dir, 50, { decrease = 3 })
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

    if GameRules:GetGameTime() - (self.startTime or 0) > 6 then
        self:Destroy()
    end
end