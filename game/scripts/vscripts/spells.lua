DUMMY_UNIT = "npc_dummy_unit"
TIMER_NAME = "ProjectileTimer"

BEHAVIOUR_DEAL_DAMAGE_AND_DESTROY = 0
BEHAVIOUR_DEAL_DAMAGE_AND_PASS = 1

THINK_PERIOD = 0.01

Spells = class({})
Projectiles = {}

WorldMin = Vector(GetWorldMinX(), GetWorldMinY(), 0)
WorldMax = Vector(GetWorldMaxX(), GetWorldMaxY(), 0)

function Spells:ThinkFunction(dt)
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return
	end

	for i = #Projectiles, 1, -1 do
		local projectile = Projectiles[i]
		projectile.prev = projectile.position

		local pos = projectile:UpdatePosition()

		if pos.x < WorldMin.x or pos.y < WorldMin.y or pos.x > WorldMax.x or pos.y > WorldMax.y then
			projectile.destroyed = true
		end

		if not projectile.destroyed then
			local status, err = pcall(
				function(projectile)
					projectile.position = pos
					projectile.dummy:SetAbsOrigin(projectile.position)
					projectile:MoveEvent(projectile.prev, projectile.position)
					projectile:DealDamage(projectile.prev, projectile.position)
				end
			, projectile)

			if not status then
				print(err)
			end
		else
			projectile:Remove()
			table.remove(Projectiles, i)
		end
	end

	return THINK_PERIOD
end

if SpellThinker == nil then
	SpellThinker = Entities:CreateByClassname("info_target") 
end

SpellThinker:SetThink("ThinkFunction", Spells, "SpellsThink", THINK_PERIOD)

function Spells:ProjectileDamage(projectile, target)
	GameRules.GameMode.Round:DealDamage(projectile.owner.playerData, target.playerData, true)
end

--[[
data:
- Vector from
- Vector to
- Float radius
- String graphics
- Entity owner

- OPTIONAL 1
- Int/Function heroBehaviour
- Function heroCondition
- Function positionMethod
- Functiom damageMethod

- OPTIONAL 2
- Function onMove
- Function onTargetReached
- Function onWallDestroy
- Vector endPoint
- Float distance
]]

function Spells:CreateProjectile(data)
	projectile = {}

	data.from = data.from or Vector(0, 0, 0)
	data.heroBehaviour = data.heroBehaviour or BEHAVIOUR_DEAL_DAMAGE_AND_DESTROY
	data.radius = data.radius or 64
	data.onTargetReached = data.onTargetReached or
		function(self)
			self:Destroy()
		end

	data.onWallDestroy = data.onWallDestroy or function() end
	data.initProjectile = data.initProjectile or
		function(self)
			data.to = data.to or Vector(0, 0, 0)

			local direction = (data.to - data.from)

			direction.z = 0.0
			direction = direction:Normalized()

			self.velocity = direction * data.velocity

			if self.distance then
				self.passed = 0
			end
		end

	data.positionMethod = data.positionMethod or 
		function(self)
			return self.position + self.velocity / 30
		end

	data.onMove = data.onMove or
		function(self, prev, pos)
			if self.distance then
				self.passed = self.passed + (pos - prev):Length2D()

				if self.passed >= self.distance then
					self:TargetReachedEvent()
				end
			end

			if self.endPoint and (self.position - self.endPoint):Length2D() <= self.radius then
				self:TargetReachedEvent()
			end
		end

	data.damageMethod = data.damageMethod or
		function(self, prevPos, curPos)
			local attacker = self.owner.playerData

			for _, player in pairs(GameRules.GameMode.Round.Players) do
				if self:HeroCondition(player, prevPos, curPos) then
					local result = self:HeroCollision(player)

					if result then
						self:Destroy()
						break
					end
				end
			end
		end

	data.heroCondition = data.heroCondition or
		function(self, target, prev, pos)
			return self.owner.playerData ~= target and SegmentCircleIntersection(prev, pos, target.hero:GetAbsOrigin(), self.radius)
		end

	if data.heroBehaviour == BEHAVIOUR_DEAL_DAMAGE_AND_DESTROY then
		data.heroBehaviour = function(self, target)
			Spells:ProjectileDamage(self, target)
			return true
		end
	end

	if data.heroBehaviour == BEHAVIOUR_DEAL_DAMAGE_AND_PASS then
		projectile.damagedGroup = {}

		data.heroBehaviour = function(self, target)
			if not self.damagedGroup[target] then
				Spells:ProjectileDamage(self, target)
				self.damagedGroup[target] = true
			end

			return false
		end
	end

	projectile.position = data.from
	projectile.radius = data.radius
	projectile.distance = data.distance
	projectile.endPoint = data.endPoint
	projectile.dummy = CreateUnitByName(DUMMY_UNIT, data.from, false, nil, nil, DOTA_TEAM_NOTEAM)
	projectile.owner = data.owner
	projectile.effectId = ParticleManager:CreateParticle(data.graphics, PATTACH_ABSORIGIN_FOLLOW , projectile.dummy)
	projectile.destroyed = false
	projectile.TargetReachedEvent = data.onTargetReached
	projectile.MoveEvent = data.onMove or function(self, prevPos, curPos) end
	projectile.HeroCondition = data.heroCondition
	projectile.HeroCollision = data.heroBehaviour
	projectile.UpdatePosition = data.positionMethod
	projectile.DealDamage = data.damageMethod
	projectile.Destroy = function(self)
		self.destroyed = true
	end

	projectile.Remove = function(self)
		UTIL_Remove(self.dummy)
		ParticleManager:DestroyParticle(self.effectId, false)
		ParticleManager:ReleaseParticleIndex(self.effectId)
	end

	data.initProjectile(projectile)
	
	table.insert(Projectiles, projectile)
end

--[[
data:
- Unit unit
- Vector to
- Float velocity
- Float radius (default 64)
- Function onArrival
]]
function Spells:Dash(data)
	data.radius = data.radius or 64
	data.velocity = data.velocity / 30
	data.onArrival = data.onArrival or function() end

	Timers:CreateTimer(
		function()
			local origin = data.unit:GetAbsOrigin()
			local diff = data.to - origin

			if diff:Length2D() <= data.radius / 2 then
				GridNav:DestroyTreesAroundPoint(data.to, data.radius, true)
				FindClearSpaceForUnit(data.unit, data.to, true)
				data.onArrival(data.unit)
				return false
			else
				local result = origin + (diff:Normalized() * data.velocity)
				data.unit:SetAbsOrigin(result)
			end

			return THINK_PERIOD
		end
	)
end

function Spells:MultipleHeroesDamage(unit, condition)
	local attacker = unit.playerData
	local round = GameRules.GameMode.Round
	local hurt = false

	if attacker == nil then
		return false
	end

	for _, player in pairs(round.Players) do
		if condition(attacker, player) then
			round:DealDamage(attacker, player, false)
			table.insert(hurt, player)
		end
	end

	if hurt then
		round:CheckEndConditions()
	end

	return hurt
end

function Spells:AreaDamage(unit, point, area)
	return Spells:MultipleHeroesDamage(unit, 
		function (attacker, target)
			local distance = (target.hero:GetAbsOrigin() - point):Length2D()

			return target ~= attacker and distance <= area
		end
	)
end

function Spells:LineDamage(unit, lineFrom, lineTo)
	return Spells:MultipleHeroesDamage(unit, 
		function (attacker, target)
			if target ~= attacker then
				return SegmentCircleIntersection(lineFrom, lineTo, target.hero:GetAbsOrigin(), target.hero:GetHullRadius())
			end
		end
	)
end

function Spells:MultipleHeroesModifier(source, ability, modifier, params, condition)
	local caster = source.playerData
	local round = GameRules.GameMode.Round

	for _, target in pairs(round.Players) do
		if condition(caster, target) then
			target.hero:AddNewModifier(source, ability, modifier, params)
		end
	end
end

function Spells:AreaModifier(source, ability, modifier, params, point, area, condition)
	return Spells:MultipleHeroesModifier(source, ability, modifier, params,
		function (caster, target)
			local distance = (target.hero:GetAbsOrigin() - point):Length2D()
			return condition(caster, target) and distance <= area
		end
	)
end