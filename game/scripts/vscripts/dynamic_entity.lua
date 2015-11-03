DynamicEntity = class({})

function DynamicEntity:constructor()
    self.size = 64
    self.position = Vector(0, 0, 0)
    self.destroyed = false
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

function DynamicEntity:Damage(source) end
function DynamicEntity:Update() end
function DynamicEntity:Remove() end