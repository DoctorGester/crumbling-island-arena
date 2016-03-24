LycanWolf = class({}, nil, DynamicEntity)

function LycanWolf:constructor(owner, target, offsetModifier)
    DynamicEntity.constructor(self)

    self.owner = owner
    self.size = 64
    self.start = owner:GetPos()
    self.target = target
    self.offsetModifier = offsetModifier
    self.attacking = nil

    self.unit = CreateUnitByName("npc_dota_lycan_wolf1", self.start, false, nil, nil, owner.unit:GetTeamNumber())
    self.unit:SetForwardVector(target - self.start)
    self.unit:AddNewModifier(owner.unit, nil, "modifier_lycan_q", { duration = 3 })

    ImmediateEffect("particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf", PATTACH_ABSORIGIN, self.unit)
end

function LycanWolf:Update()
    if not self.unit:IsAlive() then
        if self.attacking then
            local distance = (self.attacking:GetPos() - self:GetPos()):Length2D()

            if distance <= 250 then
                self.attacking:Damage(self.owner)
                self.unit:EmitSound("Arena.Lycan.HitQ2")
                self.owner:MakeBleed(self.attacking)
            end
        end

        self:Destroy()
        return
    end

    self:SetPos(self.unit:GetAbsOrigin())

    if self.attacking then
        if self.unit:IsStunned() or self.unit:IsRooted() then
            self.attacking = false
        else
            return
        end
    end

    local direction = self.target - self.start
    local normal = direction:Normalized()
    local currentPosition = self:GetPos() - self.start
    local projected = (currentPosition:Length2D() + 300) * normal

    local progress = projected:Length2D() / direction:Length2D() - 2 -- graph shifting
    local y = (progress * progress) * 128
    local offset = Vector(normal.y, -normal.x) * y * self.offsetModifier
    local result = self.start + projected + offset

    self.i = (self.i or 0) + 1

    if self.i % 5 == 0 then
        ExecuteOrderFromTable({ UnitIndex = self.unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_DIRECTION, Position = result })
    end

    if not self.unit:IsStunned() and not self.unit:IsRooted() then
        for _, target in pairs(Spells:GetValidTargets()) do
            local direction = (target:GetPos() - self:GetPos())
            local distance = direction:Length2D()

            if target ~= self.owner and distance <= 160 and target:__instanceof__(Hero) then
                ExecuteOrderFromTable({ UnitIndex = self.unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_STOP })

                self.unit:FindModifierByName("modifier_lycan_q"):SetDuration(0.5, false)
                self.unit:SetForwardVector(direction:Normalized())
                self.attacking = target
                self.unit:EmitSound("Arena.Lycan.HitQ")
                StartAnimation(self.unit, { duration = 0.5, activity = ACT_DOTA_ATTACK })
                break
            end
        end
    end
end

function LycanWolf:Remove()
    self.unit:RemoveModifierByName("modifier_lycan_q")
end

function LycanWolf:Damage(source)
    self:Destroy()
end

function LycanWolf:HasModifier(modifier)
    return self.unit:HasModifier(modifier)
end

function LycanWolf:AddNewModifier(source, ability, modifier, params)
    self.unit:AddNewModifier(source.unit, ability, modifier, params)
end

function LycanWolf:RemoveModifier(name)
    self.unit:RemoveModifierByName(name)
end

function LycanWolf:FindModifier(name)
    return self.unit:FindModifierByName(name)
end
