Obstacle = Obstacle or class({}, nil, UnitEntity)

function Obstacle:constructor(model, target)
    getbase(Obstacle).constructor(self, nil, DUMMY_UNIT, target)

    self.collisionType = COLLISION_TYPE_RECEIVER
    self.owner = { team = 0 }

    self:GetUnit():SetModel(model)
    self:GetUnit():SetOriginalModel(model)
    self:SetFacing(RandomVector(1))

    self:AddNewModifier(self, nil, "modifier_obstacle", {})
    self:RegenerateNavBlock()
    self:FindPolygon()
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
end

function Obstacle:RegenerateNavBlock()
    self:ClearObstruction()

    self.obstruction = SpawnEntityFromTableSynchronous("point_simple_obstruction", {
        origin = self:GetPos(),
    })
end

function Obstacle:AllowAbilityEffect()
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
    getbase(Obstacle).Remove(self)

    self:ClearObstruction()
end

function Obstacle:Update()
    getbase(Obstacle).Update(self)

    if not self.launched and not GridNav:IsBlocked(self:GetPos()) then
        print("Navblock regenerated for", self)
        self:RegenerateNavBlock()
    end
end