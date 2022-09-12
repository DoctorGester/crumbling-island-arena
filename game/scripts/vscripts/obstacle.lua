Obstacle = Obstacle or class({}, nil, UnitEntity)

function Obstacle:constructor(model, target)
    getbase(Obstacle).constructor(self, nil, DUMMY_UNIT, target)

    self.collisionType = COLLISION_TYPE_RECEIVER
    self.owner = { team = 0 }

    self.prop = SpawnEntityFromTableSynchronous("prop_dynamic", {
        origin = target,
        model = model
    })

    self:AddNewModifier(self, nil, "modifier_obstacle", {})
    self:RegenerateNavBlock()
    self:FindPolygon()

    self.rotation = Quat.fromAxisAngle(0, 0, 1, 0)--math.random() * math.pi * 2)
    self.health = 5

    self:GetUnit():SetBaseMaxHealth(self.health)
    self:GetUnit():SetMaxHealth(self.health)
    self:GetUnit():SetHealth(self.health)

    self.prop:SetParent(self:GetUnit(), nil)
    self.prop:SetOrigin(target)

    self.prop:SetSkin(0)
    self.prop:SetBodygroupByName("default", 1)

    self:SetAnglesFromQuaternion(self.rotation)
end

function Obstacle:SetRenderColor(r, g, b)
    self.prop:SetRenderColor(r, g, b)
end

function Obstacle:CanFall()
    return false
end

function Obstacle:GetPos()
    return self.unit:GetAbsOrigin()
end

function Obstacle:DealOneDamage(source)
    self.health = self.health - 1

    local duration

    if self.health > 2 then
        duration = 2.0
    else
        self:RemoveModifier("modifier_custom_healthbar")
    end

    self:AddNewModifier(self, nil, "modifier_custom_healthbar", { duration = duration })

    if self.health <= 0 then
        local hero = source
        if hero.hero then hero = hero.hero end

        TreeHealProjectile(nil, hero, hero, self:GetPos()):Activate()
        self:Destroy()
    else
        self:GetUnit():SetHealth(self.health)
    end

    self:Push(self:GetPos() - source:GetPos())
end

function Obstacle:FindPolygon()
    local level = GameRules.GameMode.level
    local pos = self:GetPos()

    local poly = level:GetClosestPolygonAt(pos.x, pos.y, true)

    if not poly then
        poly = level:GetClosestPolygonAt(pos.x, pos.y, false)
    end

    if poly then
        level:AddPartChild(poly.part, self)
    end
end

function Obstacle:OnLaunched(parent)
    self:ClearObstruction()
    self:AddComponent(ExpirationComponent(2.0))
    self.launched = true
    self.collisionType = COLLISION_TYPE_NONE
end

function Obstacle:RegenerateNavBlock()
    self:ClearObstruction()

    self.obstruction = SpawnEntityFromTableSynchronous("point_simple_obstruction", {
        origin = self:GetPos(),
    })
end

function Obstacle:AllowAbilityEffect(source, ability)
    return false
end

function Obstacle:CollideWith(target)
    if instanceof(target, Projectile) and target.continueOnHit then
        -- Configure inside of projectile?
        if instanceof(target, ProjectilePAA) or instanceof(target, TinyQ) then
            target:Deflect(target.hero, -target.vel)
        elseif not target.goesThroughTrees then
            target:Destroy()

            local mode = GameRules:GetGameModeEntity()

            FX("particles/ui/ui_generic_treasure_impact.vpcf", PATTACH_ABSORIGIN, mode, {
                cp0 = target:GetPos(),
                cp1 = target:GetPos(),
                release = true
            })
        end
    end
end

function Obstacle:ClearObstruction()
    if self.obstruction then
        self.obstruction:RemoveSelf()
        self.obstruction = nil
    end
end

function Obstacle:MakeFall()
    getbase(Obstacle).MakeFall(self)

    self:ClearObstruction()
end

function Obstacle:Remove()
    if self.launched or self.health <= 0 then
        self:EmitSound("Arena.TreeFall", self:GetPos())

        FX("particles/world_destruction_fx/tree_destroy.vpcf", PATTACH_WORLDORIGIN, GameRules:GetGameModeEntity(), {
            cp0 = self:GetPos(),
            cp3 = Vector(255, 255, 255)
        })
    end

    getbase(Obstacle).Remove(self)

    self:ClearObstruction()
end

function Obstacle:SetAnglesFromQuaternion(q)
    local yaw, pitch, roll = Quat.toEuler(q)

    self.prop:SetAngles(math.deg(yaw), math.deg(pitch), math.deg(roll))
end

function Obstacle:Update()
    getbase(Obstacle).Update(self)

    if not self.launched and not GridNav:IsBlocked(self:GetPos()) then
        print("Navblock regenerated for", self)
        self:RegenerateNavBlock()
    end

    self.rotation = self.rotation or Quat.fromAxisAngle(0, 0, 1, math.random() * math.pi * 2)

    local resultRot = self.rotation

    if self.pushNormal then
        local timePassed = GameRules:GetGameTime() - self.pushStartTime
        local angle = math.sin(GameRules:GetGameTime() * 24) * (self.pushAmplitude * (1 - timePassed))
        local rotAxis = Quat.fromAxisAngle(self.pushNormal.x, self.pushNormal.y, self.pushNormal.z, angle)

        resultRot = Quat.mul(resultRot, rotAxis)

        if timePassed > 1.0 then
            self.pushNormal = nil
            self.pushAmplitude = 0
        end

        self:SetAnglesFromQuaternion(resultRot)
    end
end

function Obstacle:Push(vel)
    self.pushNormal = Vector(-vel.y, vel.x):Normalized()
    self.pushStartTime = GameRules:GetGameTime()
    self.pushAmplitude = math.min((self.pushAmplitude or 0) + RandomFloat(0.05, 0.1), 0.3)

    --DebugDrawLine(self:GetPos(), self:GetPos() + self.pushNormal:Normalized() * 300, 0, 255, 0, true, 2.0)
end

TreeHealProjectile = TreeHealProjectile or class({}, nil, HomingProjectile)

function TreeHealProjectile:constructor(round, hero, target, pos)
    getbase(TreeHealProjectile).constructor(self, round, {
        owner = hero,
        from = pos + Vector(0, 0, 64),
        heightOffset = 64,
        target = target,
        speed = 900,
        graphics = "particles/tree_heal_projectile.vpcf",
        hitFunction = function(projectile, target)
            projectile:AddOrRefreshTreeHealModifier(target)
        end
    })
end

function TreeHealProjectile:AddOrRefreshTreeHealModifier(target)
    local modifier = target:FindModifier("modifier_tree_heal")

    if not modifier then
        modifier = target:AddNewModifier(target, nil, "modifier_tree_heal", {})
    else
        modifier:SetStackCount(2)
    end
end

function TreeHealProjectile:CollidesWith(target)
    return target == self.target
end