COLLISION_TYPE_NONE = 0
COLLISION_TYPE_INFLICTOR = 1
COLLISION_TYPE_RECEIVER = 2

DynamicEntity = DynamicEntity or class({})

function DynamicEntity:constructor(round)
    self.round = round or GameRules.GameMode.round
    self.size = 64
    self.position = Vector(0, 0, 0)
    self.destroyed = false
    self.invulnerable = false
    self.inAir = false
    self.collisionType = COLLISION_TYPE_NONE
    self.collisionConsiderOwner = true
end

function DynamicEntity:GetPos()
    return self.position
end

function DynamicEntity:SetPos(position)
    self.position = position
end

function DynamicEntity:GetRad()
    return self.size
end

function DynamicEntity:Destroy()
    self.destroyed = true
end

function DynamicEntity:EmitSound(sound)
    EmitSoundOnLocationWithCaster(self.position, sound, nil)
end

function DynamicEntity:Alive()
    return not self.destroyed
end

function DynamicEntity:CollidesWith(target)
    return self.owner ~= target.owner
end

function DynamicEntity:SetInvulnerable(value)
    self.invulnerable = value
end

function DynamicEntity:Damage(source) end
function DynamicEntity:Update() end
function DynamicEntity:Remove() end
function DynamicEntity:CollideWith(target) end

function DynamicEntity:HasModifier() return false end
function DynamicEntity:FindModifier() end
function DynamicEntity:AddNewModifier() end
function DynamicEntity:RemoveModifier() end

function DynamicEntity:Activate()
    self.round.spells:AddDynamicEntity(self)
end

function DynamicEntity:MultipleTargetsDamage(condition)
    local hurt = false

    for _, target in pairs(self.round.spells:GetValidTargets()) do
        if condition(self, target) then
            target:Damage(self)
            hurt = true
        end
    end

    if hurt then
        self.round:CheckEndConditions()
    end

    return hurt
end

function DynamicEntity:AreaDamage(point, area, action)
    return self:MultipleTargetsDamage(
        function (attacker, target)
            local distance = (target:GetPos() - point):Length2D()

            if target ~= attacker and distance <= area then
                if action then
                    action(target)
                end

                return true
            end

            return false
        end
    )
end

function DynamicEntity:LineDamage(lineFrom, lineTo, lineWidth, action)
    return self:MultipleTargetsDamage(
        function (attacker, target)
            if target ~= attacker then
                if SegmentCircleIntersection(lineFrom, lineTo, target:GetPos(), target:GetRad() + (lineWidth or 0)) then
                    if action then
                        action(target)
                    end

                    return true
                end

                return false
            end
        end
    )
end

function DynamicEntity:MultipleHeroesModifier(ability, modifier, params, condition)
    for _, target in pairs(self.round.spells:GetValidTargets()) do
        if target.AddNewModifier and condition(self, target) then
            target:AddNewModifier(self, ability, modifier, params)
        end
    end
end

function DynamicEntity:AreaModifier(ability, modifier, params, point, area, condition)
    return self:MultipleHeroesModifier(ability, modifier, params,
        function (source, target)
            local distance = (target:GetPos() - point):Length2D()
            return condition(source, target) and distance <= area
        end
    )
end