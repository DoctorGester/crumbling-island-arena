EarthSpiritRemnant = EarthSpiritRemnant or class({}, nil, UnitEntity)

function EarthSpiritRemnant:constructor(owner, target, direction, ability)
    getbase(EarthSpiritRemnant).constructor(self, nil, DUMMY_UNIT, target)

    self.owner = { team = -1 }
    self.hero = owner
    self.health = 2
    self.fell = false
    self.collisionType = COLLISION_TYPE_RECEIVER
    self.invulnerable = true

    self.standingHero = nil
    self.removeOnDeath = true

    self:SetFacing(direction * Vector(1, 1, 0))
    self:SetPos(target)

    self.initializationDelay = 10
    self.ability = ability

    -- Deathmatch only
    self.dontCleanup = true
end

function EarthSpiritRemnant:CanFall()
    return self.fell
end

function EarthSpiritRemnant:MakeFall(...)
    getbase(EarthSpiritRemnant).MakeFall(self, ...)

    if self.standingHero ~= nil then
        self.standingHero:FallFromStand()
        self:SetStandingHero(nil)
    end
end

function EarthSpiritRemnant:UpdateChildren()
    if self.standingHero then
        self.standingHero:SetPos(self:GetPos() + Vector(0, 0, 150))
    end
end

function EarthSpiritRemnant:FindClearSpace(...)
    getbase(EarthSpiritRemnant).FindClearSpace(self, ...)

    self:UpdateChildren()
end

function EarthSpiritRemnant:SetPos(pos)
    getbase(EarthSpiritRemnant).SetPos(self, pos)

    self:UpdateChildren()
end

function EarthSpiritRemnant:SetStandingHero(hero)
    if hero ~= nil then
        local source = hero:FindAbility("earth_spirit_q")

        hero:AddNewModifier(hero, source, "modifier_earth_spirit_stand", {})
    elseif self.standingHero ~= nil then
        self.standingHero:RemoveModifier("modifier_earth_spirit_stand")
    end

    self.standingHero = hero
end

function EarthSpiritRemnant:SetUnit(unit, fall)
    getbase(EarthSpiritRemnant).SetUnit(self, unit) 

    self.fell = not fall
    self.unit.hero = self
end

function EarthSpiritRemnant:EarthCollision()
    local pos = self:GetPos()

    if self:TestFalling() then
        ImmediateEffectPoint("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf", PATTACH_CUSTOMORIGIN, self.hero, pos)
        ImmediateEffectPoint("particles/units/heroes/hero_earth_spirit/earth_dust_hit.vpcf", PATTACH_CUSTOMORIGIN, self.hero, pos)

        local allyHeroFilter =
            Filters.WrapFilter(function(target)
                return instanceof(target, EarthSpiritRemnant) or target.owner.team ~= self.owner.team
            end)

        self.hero:AreaEffect({
            filter = Filters.Area(pos, 220) + allyHeroFilter,
            damage = self.ability:GetDamage(),
            ability = self.ability
        })

        self:AddComponent(PlayerCircleComponent(400, false, 0.5, { 34, 177, 76 }))

        ScreenShake(pos, 5, 150, 0.25, 2000, 0, true)
        Spells:GroundDamage(pos, 220, self.hero)
        self.invulnerable = false
        
        EmitSoundOnLocationWithCaster(pos, "Arena.Earth.CastQ", nil)
    else
        self.fallingSpeed = 200
    end
end

function EarthSpiritRemnant:Update()
    getbase(EarthSpiritRemnant).Update(self)

    self.initializationDelay = self.initializationDelay - 1

    if self.initializationDelay == 0 then
        self:AddNewModifier(self, nil, "modifier_earth_spirit_remnant", {})
        self:AddComponent(HealthComponent())
        self:SetCustomHealth(2)
        self:EnableHealthBar()
    end

    local earthSpirit = self.round.spells:FilterEntities(
    function(ent)
        return instanceof(ent, EarthSpirit) and ent:Alive()
    end
    )[1]

    if not earthSpirit then
        self:Destroy()
        return
    end

    if self.falling then
        return
    end

    self:UpdateChildren()

    if not self.fell then
        local pos = self:GetPos()
        local ground = GetGroundHeight(pos, self.unit)
        local z = math.max(ground, pos.z - 200)
        self:SetPos(Vector(pos.x, pos.y, z))

        if z == ground then
            self.fell = true
            self:EarthCollision()
        end
    else
        local modifierFilter = Filters.WrapFilter(function(target)
            return target:HasModifier("modifier_earth_spirit_a")
        end)

        local hit = self:AreaEffect({
            filter = Filters.Area(self:GetPos(), 400) + modifierFilter,
            ability = self.ability,
            sound = "Arena.Earth.ProcA",
            action = function(target)
                local mod = target:FindModifier("modifier_earth_spirit_a")

                if mod then
                    target:Damage(mod:GetCaster():GetParentEntity(), 1)
                end

                target:RemoveModifier("modifier_earth_spirit_a")
            end,
            notBlockedAction = function(target)
                FX("particles/units/heroes/hero_earth_spirit/espirit_magnet_arclightning.vpcf", PATTACH_ABSORIGIN, self, {
                    cp0 = self:GetPos() + Vector(0, 0, 100),
                    cp1 = { ent = target, point = "attach_hitloc" },
                    release = true
                })
            end
        })

        if hit then
            FX("particles/units/heroes/hero_earth_spirit/espirit_stone_explosion.vpcf", PATTACH_ABSORIGIN, self, {
                cp1 = Vector(400, 1, 1),
                release = true
            })

            ScreenShake(self:GetPos(), 5, 150, 0.25, 2000, 0, true)
        end
    end
end

function EarthSpiritRemnant:OnDeath(source)
    if instanceof(source, EarthSpirit) then
        FX("particles/units/heroes/hero_earth_spirit/espirit_magnet_arclightning.vpcf", PATTACH_ABSORIGIN, source, {
            cp0 = self:GetPos() + Vector(0, 0, 100),
            cp1 = { ent = source, point = "attach_hitloc" },
            release = true
        })

        source:EmitSound("Arena.Earth.ProcA")

        ScreenShake(self:GetPos(), 5, 150, 0.25, 2000, 0, true)

        source:Heal(2)
    end
end

function EarthSpiritRemnant:Remove()
    if self.unit then
        self.unit:StopSound("Arena.Earth.CastW.Loop")
        self.unit:EmitSound("Arena.Earth.EndQ")
    end

    ImmediateEffectPoint("particles/units/heroes/hero_earth_spirit/earthspirit_petrify_shockwave.vpcf", PATTACH_CUSTOMORIGIN, self.hero, self:GetPos())

    if self.standingHero ~= nil and not self.standingHero.destroyed then
        self.standingHero:FallFromStand()
        self:SetStandingHero(nil)
    end

    getbase(EarthSpiritRemnant).Remove(self)
end