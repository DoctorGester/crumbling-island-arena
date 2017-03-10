Obstacle = Obstacle or class({}, nil, UnitEntity)

function Obstacle:constructor(model, target)
    getbase(Obstacle).constructor(self, nil, DUMMY_UNIT, target)

    self.collisionType = COLLISION_TYPE_RECEIVER
    self.owner = { team = 0 }

    self:GetUnit():SetModel(model)
    self:GetUnit():SetOriginalModel(model)

    self:AddNewModifier(self, nil, "modifier_obstacle", {})
    self:RegenerateNavBlock()
    self:FindPolygon()

    self.rotation = Quat.fromAxisAngle(0, 0, 1, math.random() * math.pi * 2)
    self.health = 5

    self:GetUnit():SetBaseMaxHealth(self.health)
    self:GetUnit():SetMaxHealth(self.health)
    self:GetUnit():SetHealth(self.health)

    self:SetAnglesFromQuaternion(self.rotation)
end

function Obstacle:CanFall()
    return false
end

function Obstacle:GetPos()
    return self.unit:GetAbsOrigin()
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
    if ability.GetDamage then
        self.health = self.health - 1
        self:AddNewModifier(self, nil, "modifier_custom_healthbar", { duration = 2.0 })

        if self.health <= 0 then
            self:Destroy()
        else
            self:GetUnit():SetHealth(self.health)
        end

        self:Push(Vector())
    end

    return false
end

function Obstacle:CollideWith(target)
    if instanceof(target, Projectile) and target.continueOnHit then
        if instanceof(target, ProjectilePAA) then
            target:Deflect(target.hero, -target.vel)
        else
            target:Destroy()

            local mode = GameRules:GetGameModeEntity()

            FX("particles/ui/ui_generic_treasure_impact.vpcf", PATTACH_ABSORIGIN, mode, {
                cp0 = target:GetPos(),
                cp1 = target:GetPos(),
                release = true
            })

            FX("particles/msg_fx/msg_deny.vpcf", PATTACH_CUSTOMORIGIN, mode, {
                cp0 = target:GetPos(),
                cp3 = Vector(200, 0, 0),
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
    self:EmitSound("Arena.TreeFall")

    FX("particles/world_destruction_fx/tree_destroy.vpcf", PATTACH_WORLDORIGIN, GameRules:GetGameModeEntity(), {
        cp0 = self:GetPos(),
        cp3 = Vector(255, 255, 255)
    })

    getbase(Obstacle).Remove(self)

    self:ClearObstruction()
end

function Obstacle:SetAnglesFromQuaternion(q)
    local yaw, pitch, roll = Quat.toEuler(q)

    self:GetUnit():SetAngles(math.deg(yaw), math.deg(pitch), math.deg(roll))
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
        local angle = math.sin(GameRules:GetGameTime() * 24) * (0.05 * (1 - timePassed))
        --local rotAxis = Quat.fromAxisAngle(self.pushNormal.x, self.pushNormal.y, self.pushNormal.z, angle)
        local rotAxis = Quat.fromAxisAngle(0, 1, 0, angle)

        resultRot = Quat.mul(rotAxis, resultRot)

        if timePassed > 1.0 then
            self.pushNormal = nil
        end

        self:SetAnglesFromQuaternion(resultRot)
    end
end

function Obstacle:Push(vel)
    self.pushNormal = Vector(-vel.y, vel.x):Normalized()
    self.pushStartTime = GameRules:GetGameTime()

    --DebugDrawLine(self:GetPos(), self:GetPos() + self.pushNormal:Normalized() * 300, 0, 255, 0, true, 2.0)
end