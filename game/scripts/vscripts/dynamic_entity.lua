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
    self.collisionType = COLLISION_TYPE_NONE
    self.collisionConsiderOwner = true
    self.falling = false
    self.fallingSpeed = 0
end

function DynamicEntity:AddComponent(component)
    if component.Activate then
        component.Activate(self)
    end

    for key, value in pairs(component) do
        if key ~= "Activate" then
            if self[key] ~= nil then
                print("Warning! Colliding key", key)
            end

            self[key] = value
        end
    end

    return self
end

function DynamicEntity:MakeFall(horizontalVelocity)
    self.falling = true
    self.fallingHorizontalVelocity = horizontalVelocity or Vector()
end

function DynamicEntity:CanFall()
    return true
end

function DynamicEntity:GetPos()
    return self.position
end

function DynamicEntity:SetPos(position)
    self.position = position

    return self
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
    return true
end

function DynamicEntity:SetInvulnerable(value)
    self.invulnerable = value
end

function DynamicEntity:IsInvulnerable(value)
    return self.invulnerable
end

function DynamicEntity:Update()
    Spells.SystemCallSingle(self, "Update")

    if self.falling then
        self.fallingSpeed = self.fallingSpeed + 10
        local pos = self:GetPos()

        local t = pos - Vector(0, 0, self.fallingSpeed / 3)

        if self.fallingHorizontalVelocity then
            if pos.z > -100 then
                local hit = Spells.TestCircle(pos + self.fallingHorizontalVelocity * 0.5, self:GetRad())

                if hit then
                    self.fallingHorizontalVelocity = -self.fallingHorizontalVelocity * 0.5
                end
            end

            t = t + self.fallingHorizontalVelocity
        end

        self:SetPos(t)

        if pos.z <= -MAP_HEIGHT then
            self:Destroy()

            if self.SetHidden then
                self:SetHidden(true)
            end
        end
    end
end

function DynamicEntity:TestFalling()
    return Spells.TestCircle(self:GetPos(), self:GetRad())
end


function DynamicEntity:Damage(source, amount, isPhysical)
    Spells.SystemCallSingle(self, "Damage", source, amount, isPhysical)
end

function DynamicEntity:Heal() end

function DynamicEntity:Remove()
    Spells.SystemCallSingle(self, "Remove")
end

function DynamicEntity:CollideWith(target) end

function DynamicEntity:HasModifier() return false end
function DynamicEntity:FindModifier() end
function DynamicEntity:AddNewModifier() end
function DynamicEntity:RemoveModifier() end
function DynamicEntity:IsAirborne()
    return false
end
function DynamicEntity:AllModifiers()
    return {}
end

function DynamicEntity:AllowAbilityEffect(source, ability)
    if not self:Alive() then
        return true
    end

    for _, modifier in pairs(self:AllModifiers()) do
        if modifier.AllowAbilityEffect and modifier:AllowAbilityEffect(source, ability) == false then
            return false
        end
    end

    return true
end

function DynamicEntity:Activate()
    self.round.spells:AddDynamicEntity(self)

    return self
end

function DynamicEntity:AreaEffect(params)
    local hurt

    if params.damage == true then
        params.damage = 3
    end

    local soundPlayed = false

    for _, target in pairs(self.round.spells:GetValidTargets()) do
        local passes = not instanceof(target, Projectile) or ((IsAttackAbility(params.ability) and IsAttackAbility(target.ability)) or params.targetProjectiles)
        local heroPasses = not params.onlyHeroes or instanceof(target, Hero)
        local allyFilter = false

        if target.owner then
            allyFilter = target.owner.team ~= self.owner.team or (params.hitAllies and (target ~= self or params.hitSelf))
        end

        if allyFilter and passes and heroPasses and params.filter(target) then
            local blocked = params.ability and target:AllowAbilityEffect(self, params.ability) == false

            if params.modifier and not blocked then
                local m = params.modifier

                target:AddNewModifier(self, m.ability, m.name, { duration = m.duration })
            end

            if params.damage ~= nil and not blocked then
                target:Damage(self, params.damage, params.isPhysical)
            end

            if params.knockback and not blocked then
                local direction = params.knockback.direction and params.knockback.direction(target) or (target:GetPos() - self:GetPos())

                local force = params.knockback.force
                local decrease = params.knockback.decrease

                if type(force) == "function" then
                    force = force(target)
                end

                if type(decrease) == "function" then
                    decrease = decrease(target)
                end

                SoftKnockback(target, self, direction, force or 20, {
                    decrease = decrease,
                    knockup = params.knockback.knockup
                })
            end

            if params.action and not blocked then
                params.action(target)
            end

            if params.notBlockedAction then
                params.notBlockedAction(target, blocked)
            end

            if params.sound and not soundPlayed then
                if type(params.sound) == "table" then
                    for _, sound in pairs(params.sound) do
                        target:EmitSound(sound)
                    end
                else
                    target:EmitSound(params.sound)
                end

                soundPlayed = true
            end

            if not hurt then
                hurt = {}
            end

            table.insert(hurt, target)
        end
    end

    return hurt
end