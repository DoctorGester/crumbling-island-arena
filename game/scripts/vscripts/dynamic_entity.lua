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

function DynamicEntity:Update()
    if self.falling then
        self.fallingSpeed = self.fallingSpeed + 10

        self:SetPos(self:GetPos() - Vector(0, 0, self.fallingSpeed / 3))

        if self:GetPos().z <= -MAP_HEIGHT then
            self:Destroy()

            SplashEffect(self:GetPos())
        end
    end
end

function DynamicEntity:Damage(source) end
function DynamicEntity:Heal() end
function DynamicEntity:Remove() end
function DynamicEntity:CollideWith(target) end

function DynamicEntity:HasModifier() return false end
function DynamicEntity:FindModifier() end
function DynamicEntity:AddNewModifier() end
function DynamicEntity:RemoveModifier() end

function DynamicEntity:Activate()
    self.round.spells:AddDynamicEntity(self)

    return self
end

function DynamicEntity:AreaEffect(params)
    local hurt = nil

    for _, target in pairs(self.round.spells:GetValidTargets()) do
        local passes = not params.filterProjectiles or not instanceof(target, Projectile)

        if (target ~= self or params.affectsCaster) and passes and params.filter(target) then
            if params.modifier then
                local m = params.modifier

                target:AddNewModifier(self, m.ability, m.name, { duration = m.duration })
            end

            if params.damage then
                target:Damage(self)
            end

            if params.action then
                params.action(target)
            end

            if params.sound then
                target:EmitSound(params.sound)
            end

            if not hurt then
                hurt = {}
            end

            table.insert(hurt, target)
        end
    end

    return hurt
end