UnitEntity = UnitEntity or class({}, nil, DynamicEntity)

function UnitEntity:constructor(round, unitName, pos, team, findSpace, playerOwner)
	getbase(UnitEntity).constructor(self, round)

    if findSpace == nil then
        findSpace = false
    end
    
	if unitName then
		self:SetUnit(CreateUnitByName(unitName, pos, findSpace, nil, nil, team or DOTA_TEAM_NOTEAM))

        if playerOwner then
            self:AddNewModifier(self, nil, "modifier_player_id", {}):SetStackCount(playerOwner.id)
        end
	end

	self.removeOnDeath = true
	self.modifierImmune = false
	self.soundsStarted = {}

	if pos then
		getbase(UnitEntity).SetPos(self, pos)
	end
end

function UnitEntity:SetHidden(hidden)
    Spells.SystemCallSingle(self, "SetHidden", hidden)

    if hidden then
        self.unit:AddNoDraw()
    else
        self.unit:RemoveNoDraw()
    end
end

function UnitEntity:GetName()
    return self.unit:GetName()
end

function UnitEntity:MakeFall(horVel)
    getbase(UnitEntity).MakeFall(self, horVel)

    self:AddNewModifier(self, nil, "modifier_falling", {})
end

function UnitEntity:GetUnit()
	return self.unit
end

function UnitEntity:SetUnit(unit)
	self.unit = unit

    self.unit.GetParentEntity = function(unit)
        return self
    end
end

function UnitEntity:SetPos(pos)
    getbase(UnitEntity).SetPos(self, pos)

    if self:GetUnit() then
	    self:GetUnit():SetAbsOrigin(pos)
	end
end

function UnitEntity:GetFacing()
    return self.unit:GetForwardVector()
end

function UnitEntity:EmitSound(sound, location)
	if self.destryoed then
		return
	end

	if location then
		EmitSoundOnLocationWithCaster(location, sound, self.unit)
	else
		print("[SOUNDS]", "Emit", sound)
		self.unit:EmitSound(sound)
		self.soundsStarted[sound] = GameRules:GetGameTime()
	end
end

function UnitEntity:StopSound(sound)
	if IsValidEntity(self.unit) then
		print("[SOUNDS]", "Stop", sound)

		local originalTime = self.soundsStarted[sound] or 0
		local time = (GameRules:GetGameTime() - originalTime) - 0.1

		if time < 0 then
			print("[SOUNDS]", "Trying to stop", sound, "waiting for", -time)

			Timers:CreateTimer(-time, function()
				if (self.soundsStarted[sound] or 0) == originalTime then -- Sound was not restarted after stop
					self:GetUnit():StopSound(sound)
					self.soundsStarted[sound] = nil
				else
					print("[SOUNDS]", sound, "was restarted, new time", self.soundsStarted[sound])
				end
			end)
		else
			self.soundsStarted[sound] = nil
			self:GetUnit():StopSound(sound)
		end

		return -time
	end
end

function UnitEntity:SetFacing(facing)
	self.unit:SetForwardVector(facing)
end

function UnitEntity:AddNewModifier(source, ability, modifier, params)
	if not self.modifierImmune then
		local from = source

		if source and source.unit then
			from = source.unit
		end

		return self.unit:AddNewModifier(from, ability, modifier, params)
	end
end

function UnitEntity:HasModifier(modifier)
	return self.unit:HasModifier(modifier)
end

function UnitEntity:RemoveModifier(name)
	self.unit:RemoveModifierByName(name)
end

function UnitEntity:FindModifier(name, optionalCaster)
	if optionalCaster then
		return self.unit:FindModifierByNameAndCaster(name, optionalCaster.unit or optionalCaster)
	end

	return self.unit:FindModifierByName(name)
end

function UnitEntity:AllModifiers()
	return self.unit:FindAllModifiers()
end

function UnitEntity:GetGroundHeight(position)
	return GetGroundHeight(position or self:GetPos(), self.unit)
end

function UnitEntity:FindClearSpace(position, force)
	getbase(UnitEntity).SetPos(self, position)

	FindClearSpaceForUnit(self.unit, position, force)
end

function UnitEntity:Remove()
	getbase(UnitEntity).Remove(self)

	if self.removeOnDeath then
		local maxTime = 0

		for sound, _ in pairs(self.soundsStarted) do
			maxTime = math.max(self:StopSound(sound) or 0, maxTime)
		end

		if maxTime > 0 then
			print("[SOUNDS]", "Delayed entity removal, waiting for", maxTime)
			self:GetUnit():ForceKill(false)
			self:GetUnit():SetAbsOrigin(self:GetPos())

			Timers:CreateTimer(maxTime, function()
				-- At least one entry encountered means there are more sounds
				for sound, _ in pairs(self.soundsStarted) do
					print("[SOUNDS]", "At least", sound, "is left, waiting")
					return 0.01
				end

				self:GetUnit():RemoveSelf()
			end)
		else
			self:GetUnit():RemoveSelf()
		end
	else
		self:GetUnit():ForceKill(false)
		self:GetUnit():SetAbsOrigin(self:GetPos())
	end
end