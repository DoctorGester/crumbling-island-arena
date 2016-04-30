WKSkeleton = WKSkeleton or class({}, nil, UnitEntity)

function WKSkeleton:constructor(round, owner, ability, position, direction)
    getbase(WKSkeleton).constructor(self, round, "npc_dota_dark_troll_warlord_skeleton_warrior", position, owner.unit:GetTeamNumber())

    self.ability = ability
    self.owner = owner.owner
    self.hero = owner
    self.size = 64
    self.start = position
    self.direction = direction
    self.removeOnDeath = false
    self.attacking = nil
    self.collisionType = COLLISION_TYPE_INFLICTOR

    self:SetFacing(direction)
    self:AddNewModifier(self.hero, nil, "modifier_wk_skeleton", { duration = 3 })

    if owner.owner then
        self:GetUnit():SetControllableByPlayer(owner.owner.id, true)
    end
end

function WKSkeleton:GetPos()
    return self:GetUnit():GetAbsOrigin()
end

function WKSkeleton:CollidesWith(target)
    return self.owner.team ~= target.owner.team
end

function WKSkeleton:CollideWith(target)
    local unit = self:GetUnit()

    if instanceof(target, Hero) and not unit:IsStunned() and not unit:IsRooted() then
        local direction = (target:GetPos() - self:GetPos())
        local distance = direction:Length2D()

        ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_STOP })

        self:FindModifier("modifier_wk_skeleton"):SetDuration(0.25, false)
        self:SetFacing(direction:Normalized())
        self.attacking = target
        self.collisionType = COLLISION_TYPE_RECEIVER
        self:EmitSound("Arena.WK.HitQ")

        StartAnimation(unit, { duration = 0.25, activity = ACT_DOTA_ATTACK, rate = 1.5 })
    end
end

function WKSkeleton:Update()
    getbase(WKSkeleton).Update(self)

    if self.falling then
        return
    end

    if self:FindModifier("modifier_wk_skeleton"):GetRemainingTime() <= 0 then
        if self.attacking then
            local distance = (self.attacking:GetPos() - self:GetPos()):Length2D()

            if distance <= 250 then
                local modifier = self.attacking:FindModifier("modifier_wk_q")

                if not modifier then
                    self.attacking:Damage(self)
                    modifier = self.attacking:AddNewModifier(self.hero, self.ability, "modifier_wk_q", { duration = 3 })

                    if modifier then
                        modifier:SetStackCount(1)
                    end
                else
                    modifier:IncrementStackCount()
                end

                self:EmitSound("Arena.WK.HitQ2")
            end
        end

        self:Destroy()
        return
    end

    if self.attacking then
        if self:GetUnit():IsStunned() or self:GetUnit():IsRooted() then
            self.collisionType = COLLISION_TYPE_INFLICTOR
            self.attacking = false
        end

        return
    end

    local result = ClampToMap(self.start + self.direction * 5000)

    self.i = (self.i or 20) + 1

    if self.i % 30 == 0 then
        ExecuteOrderFromTable({ UnitIndex = self:GetUnit():GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_DIRECTION, Position = result })
    end
end

function WKSkeleton:TestFalling(source)
    return Spells.TestPoint(self:GetPos(), self:GetUnit())
end

function WKSkeleton:Damage(source)
    self:Destroy()
end