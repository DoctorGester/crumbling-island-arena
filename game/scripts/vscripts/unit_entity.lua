UnitEntity = UnitEntity or class({}, nil, DynamicEntity)

function UnitEntity:constructor(round, unitName, pos, team)
	getbase(UnitEntity).constructor(self, round)

	self.unit = CreateUnitByName(unitName or DUMMY_UNIT, pos, false, nil, nil, team or DOTA_TEAM_NOTEAM)
	self.removeOnDeath = true
	self.modifierImmune = false

	getbase(UnitEntity).SetPos(self, pos)
end

function UnitEntity:MakeFall()
    getbase(UnitEntity).MakeFall(self)

    self:AddNewModifier(self, nil, "modifier_falling", {})
end

function UnitEntity:GetUnit()
	return self.unit
end

function UnitEntity:SetPos(pos)
    getbase(UnitEntity).SetPos(self, pos)

    self:GetUnit():SetAbsOrigin(pos)
end

function UnitEntity:GetFacing()
    return self.unit:GetForwardVector()
end

function UnitEntity:EmitSound(sound, location)
    if location then
        EmitSoundOnLocationWithCaster(location, sound, self.unit)
    else
        self.unit:EmitSound(sound)
    end
end

function UnitEntity:StopSound(sound)
	self.unit:StopSound(sound)
end

function UnitEntity:SetFacing(facing)
    self.unit:SetForwardVector(facing)
end

function UnitEntity:AddNewModifier(source, ability, modifier, params)
	if not self.modifierImmune then
	    return self.unit:AddNewModifier(source.unit or source, ability, modifier, params)
	end
end

function UnitEntity:HasModifier(modifier)
    return self.unit:HasModifier(modifier)
end

function UnitEntity:RemoveModifier(name)
    self.unit:RemoveModifierByName(name)
end

function UnitEntity:FindModifier(name)
    return self.unit:FindModifierByName(name)
end

function UnitEntity:AllModifiers()
	return self.unit:FindAllModifiers()
end

function UnitEntity:GetGroundHeight(position)
    return GetGroundHeight(position or self:GetPos(), self.unit)
end

function UnitEntity:FindClearSpace(position, force)
    FindClearSpaceForUnit(self.unit, position, force)
end

function UnitEntity:Remove()
	if self.removeOnDeath then
		self:GetUnit():RemoveSelf()
	else
		local pos = self:GetPos()

	    self:GetUnit():ForceKill(false)
		self:GetUnit():SetAbsOrigin(pos)
	end
end