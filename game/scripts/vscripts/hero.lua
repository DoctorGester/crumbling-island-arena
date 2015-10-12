FALL_ABILITY = "falling_hero"

Hero = class({
	unit = nil,
	fallSpeed = 0.0,
	protected = false,
	falling = false,
	owner = nil
}, {}, nil)

function Hero:SetUnit(unit)
	self.unit = unit
	unit.hero = self
end

function Hero:SetOwner(owner)
	self.owner = owner
end

function Hero:GetName()
	return self.unit:GetName()
end

function Hero:GetPos()
	return self.unit:GetAbsOrigin()
end

function Hero:GetRad()
	return self.unit:BoundingRadius2D() * 2
end

function Hero:Alive()
	return self.unit:IsAlive()
end

function Hero:FindModifier(name)
	return self.unit:FindModifierByName(name)
end

function Hero:SetPos(pos)
	self.unit:SetAbsOrigin(pos)
end

function Hero:EmitSound(sound)
	self.unit:EmitSound(sound)
end

function Hero:Damage(source)
	if source == nil then source = self end

	if not self:Alive() or self.protected or self.falling then
		return
	end

	local damageTable = {
		victim = self.unit,
		attacker = source.unit,
		damage = 1,
		damage_type = DAMAGE_TYPE_PURE,
	}

	ApplyDamage(damageTable)
end

function Hero:Heal()
	self.unit:SetHealth(self.unit:GetHealth() + 1)
end

function Hero:EnableUltimate(ultimate)
	self.unit:FindAbilityByName(ultimate):SetLevel(1)
end

function Hero:AddNewModifier(source, ability, modifier, params)
	self.unit:AddNewModifier(source.unit, ability, modifier, params)
end

function Hero:Delete()
	self.unit:RemoveSelf()
end

function Hero:Hide()
	self.unit:SetAbsOrigin(Vector(0, 0, 10000))
	self.unit:AddNoDraw()
	AddLevelOneAbility(self.unit, "hidden_hero")
end

function Hero:StartFalling()
	self.falling = true
	AddLevelOneAbility(self.unit, FALL_ABILITY)
end

-- return true if hero died
function Hero:UpdateFalling()
	if not self:Alive() then
		return false
	end

	self.fallSpeed = self.fallSpeed + 4

	local origin = self:GetPos()
	origin.z = origin.z - self.fallSpeed
	self:SetPos(origin)

	if origin.z < -7000 then
		self.unit:ForceKill(false)
		self.unit:AddNoDraw()
		self:SetPos(origin) -- Killing a hero resets Z

		return true
	end

	return false
end

function Hero:Setup(ultimate)
	AddLevelOneAbility(self.unit, "arena_hero")
	self.unit:SetAbilityPoints(0)

	local count = self.unit:GetAbilityCount() - 1
    for i = 0, count do
    	local ability = self.unit:GetAbilityByIndex(i)

    	if ability ~= nil and not ability:IsAttributeBonus() and not ability:IsHidden()  then
    		local name = ability:GetName()

    		if string.find(name, "sub") then
    			ability:SetHidden(true)
    		end

    		if name ~= ultimate then
	    		ability:SetLevel(1)
	    	end
    	end
    end
end