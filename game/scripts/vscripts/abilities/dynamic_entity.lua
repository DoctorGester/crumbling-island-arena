DynamicEntity = class({
	size = 64,
	position = Vector(0, 0, 0),
	destroyed = false
})

function DynamicEntity:GetPos()
	return self.position
end

function DynamicEntity:SetPos(position)
	self.position = position
end

function DynamicEntity:GetRad()
	return self.size
end

function DynamicEntity:IsDynamicEntity()
	return true
end

function DynamicEntity:Destroy()
	self.destroyed = true
end

function DynamicEntity:DealDamage(source) end
function DynamicEntity:Update() end
function DynamicEntity:Remove() end