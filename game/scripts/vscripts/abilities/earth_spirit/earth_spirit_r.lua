earth_spirit_r = class({})

LinkLuaModifier("modifier_earth_spirit_r", "abilities/earth_spirit/modifier_earth_spirit_r", LUA_MODIFIER_MOTION_NONE)

function earth_spirit_r:GetChannelTime()
	return 5.0
end

function earth_spirit_r:GetChannelAnimation()
	return ACT_DOTA_OVERRIDE_ABILITY_1
end

function earth_spirit_r:GetCastPoint()
	return 0.10
end

if IsServer() then
	function earth_spirit_r:OnChannelThink(interval)
		local hero = self:GetCaster():GetParentEntity()
		local target = self:GetCursorPosition()

		if interval == 0 then
			self.modifier = hero:AddNewModifier(hero, self, "modifier_earth_spirit_r", {})

			FX("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf", PATTACH_ABSORIGIN, hero, { release = true })
			FX("particles/units/heroes/hero_earth_spirit/earth_dust_hit.vpcf", PATTACH_ABSORIGIN, hero, { release = true })
			ScreenShake(hero:GetPos(), 5, 150, 0.25, 2000, 0, true)
			hero:EmitSound("Arena.Earth.CastQ")
			hero:EmitSound("Arena.Earth.CastR")
			hero:EmitSound("Arena.Earth.CastR.Voice")

			if hero:HasRemnantStand() then
				hero:GetRemnantStand():SetStandingHero(nil)
			end
		end

		self.timePassed = (self.timePassed or 0) + interval

		if self.timePassed > 0.15 and not self.started then
			self.started = true
			self.timePassed = self.timePassed % 0.15
			self.roll = EarthSpiritRoll(self, hero, target)
		end

		if self.roll then
			self.roll.target = target
		end
	end

	function earth_spirit_r:OnChannelFinish(interrupted)
		self.timePassed = 0
		self.started = nil
		self.roll = nil

		local hero = self:GetCaster():GetParentEntity()
		hero:RemoveModifier("modifier_earth_spirit_r")
	end
end

EarthSpiritRoll = class({}, nil, Dash)

function EarthSpiritRoll:constructor(ability, hero, target)
	getbase(EarthSpiritRoll).constructor(self, hero, target, 400, {
		noFixedDuration = true,
		loopingSound = "Arena.Earth.CastW.Loop",
		hitParams = {
			ability = ability,
			damage = ability:GetDamage(),
			action = function(target)
				EarthSpiritKnockback(ability, target, hero, self.direction:Normalized(), 90, { decrease = 5 })
			end,
			notBlockedAction = function(target)
				target:EmitSound("Arena.Earth.HitR")

				if instanceof(target, Hero) then
					self:Interrupt()
				end
			end
		}
	})

	self.ability = ability
	self.target = target
	self.direction = (self.target - hero:GetPos()):Normalized()

	self:SetModifierHandle(ability.modifier)
end

function EarthSpiritRoll:HasEnded()
	return not self.hero:FindAbility("earth_spirit_r"):IsChanneling()
end

function EarthSpiritRoll:Update(...)
	getbase(EarthSpiritRoll).Update(self, ...)

	local requiredDirection = (self.target - self.hero:GetPos()):Normalized()

	local current = self.direction
	local angle = current:Dot(requiredDirection)

	self.velocity = math.max(25, self.velocity + (angle - 0.75) * 3.5)
	self.direction = LerpVectors(current, requiredDirection, 0.2)
	self.hero:GetUnit():SetAngles(0, math.deg(math.atan2(self.direction.y, self.direction.x)), 0)
end

function EarthSpiritRoll:End(...)
	getbase(EarthSpiritRoll).End(self, ...)

	self.hero:EmitSound("Arena.Earth.EndR")
	self.hero:EmitSound("Arena.Earth.CastQ")

	FX("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf", PATTACH_ABSORIGIN, self.hero, { release = true })
	FX("particles/units/heroes/hero_earth_spirit/earth_dust_hit.vpcf", PATTACH_ABSORIGIN, self.hero, { release = true })
	ScreenShake(self.hero:GetPos(), 5, 150, 0.25, 2000, 0, true)

	if self.hero:Alive() then
		if not self:HasEnded() then
			self.hero:GetUnit():Interrupt()
		end

		SoftKnockback(self.hero, self.hero, self.direction:Normalized(), 50, { decrease = 5 })
	end
end

function EarthSpiritRoll:PositionFunction(current)
	return current + self.direction * self.velocity
end

if IsServer() then
	Wrappers.GuidedAbility(earth_spirit_r, false, true)
end

if IsClient() then
	require("wrappers")
end

Wrappers.NormalAbility(earth_spirit_r)