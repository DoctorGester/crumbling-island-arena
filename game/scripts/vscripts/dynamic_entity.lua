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

function DynamicEntity:MakeFall()
    self.falling = true
end

function DynamicEntity:CanFall()
    return true
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
    return true
end

function DynamicEntity:SetInvulnerable(value)
    self.invulnerable = value
end

function DynamicEntity:IsInvulnerable(value)
    return self.invulnerable
end

function DynamicEntity:Update()
    if self.falling then
        self.fallingSpeed = self.fallingSpeed + 10

        self:SetPos(self:GetPos() - Vector(0, 0, self.fallingSpeed / 3))

        if self:GetPos().z <= -MAP_HEIGHT then
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


function DynamicEntity:Damage(source, amount, isPhysical) end
function DynamicEntity:Heal() end
function DynamicEntity:Remove() end
function DynamicEntity:CollideWith(target) end

function DynamicEntity:HasModifier() return false end
function DynamicEntity:FindModifier() end
function DynamicEntity:AddNewModifier() end
function DynamicEntity:RemoveModifier() end
function DynamicEntity:IsAirbone()
    return not self:CanFall()
end

function DynamicEntity:Activate()
    self.round.spells:AddDynamicEntity(self)

    return self
end

function DynamicEntity:AreaEffect(params)
    local hurt = nil

    params.filterProjectiles = true

    if params.damage == true then
        params.damage = 3
    end

    local soundPlayed = false

    for _, target in pairs(self.round.spells:GetValidTargets()) do
        local passes = not params.filterProjectiles or not instanceof(target, Projectile)
        local heroPasses = not params.onlyHeroes or instanceof(target, Hero)
        local allyFilter = target.owner.team ~= self.owner.team or (params.hitAllies and (target ~= self or params.hitSelf))

        if allyFilter and passes and heroPasses and params.filter(target) then
            if params.modifier then
                local m = params.modifier

                target:AddNewModifier(self, m.ability, m.name, { duration = m.duration })
            end

            if params.damage ~= nil then
                target:Damage(self, params.damage, params.isPhysical)
            end

            if params.knockback then
                local direction = params.knockback.direction and params.knockback.direction(target) or (target:GetPos() - self:GetPos())

                SoftKnockback(target, self, direction, params.knockback.force or 20, {
                    decrease = params.knockback.decrease
                })
            end

            if params.action then
                params.action(target)
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