DUMMY_UNIT = "npc_dummy_unit"
TIMER_NAME = "ProjectileTimer"

BEHAVIOUR_DEAL_DAMAGE_AND_DESTROY = 0
BEHAVIOUR_DEAL_DAMAGE_AND_PASS = 1

THINK_PERIOD = 0.01

Spells = class({})
Projectiles = {}

WorldMin = Vector(GetWorldMinX(), GetWorldMinY(), 0)
WorldMax = Vector(GetWorldMaxX(), GetWorldMaxY(), 0)

Timers:RemoveTimer(TIMER_NAME)
Timers:CreateTimer(TIMER_NAME, {
	callback =
		function()
			local destroyed = {}

			for index, projectile in ipairs(Projectiles) do
				projectile.prev = projectile.position

				local pos = projectile:UpdatePosition()

				if pos.x > WorldMin.x and pos.y > WorldMin.y and pos.x < WorldMax.x and pos.y < WorldMax.y then
					projectile.position = pos
					projectile.dummy:SetAbsOrigin(projectile.position)
				else
					table.insert(destroyed, index)
				end
			end

			table.sort(destroyed, function(a, b) return b < a end)

			for _, index in pairs(destroyed) do
				Projectiles[index]:Destroy()
				table.remove(Projectiles, index)
			end

			return THINK_PERIOD
		end
})

--[[
data:
- Vector from
- Vector to
- Float radius
- String graphics
- Entity owner
- Int/Function heroBehaviour
- Function onTargetReached
- Function onWallDestroy
- Function controlMovement
- Vector endPoint
- Float distance
]]

function Spells:CreateProjectile(data)
	projectile = {}

	data.from = data.from or Vector(0, 0, 0)
	data.lastPoint = data.from
	data.heroBehaviour = data.heroBehaviour or BEHAVIOUR_DEAL_DAMAGE_AND_DESTROY
	data.radius = data.radius or 64
	data.onTargetReached = data.onTargetReached or function() end
	data.onWallDestroy = data.onWallDestroy or function() end
	data.initProjectile = data.initProjectile or
		function(self)
			data.to = data.to or Vector(0, 0, 0)

			local direction = (data.to - data.from)

			direction.z = 0.0
			direction = direction:Normalized()

			self.velocity = direction * data.velocity
		end

	data.updatePosition = data.updatePosition or 
		function(self)
			return self.position + self.velocity * THINK_PERIOD
		end

	if data.heroBehaviour == BEHAVIOUR_DEAL_DAMAGE_AND_DESTROY then
		data.heroBehaviour = function(collider, collided, a, v)
			GameRules.GameMode.Round:DealDamage(a, v, true)
			return true
		end
	end

	if data.heroBehaviour == BEHAVIOUR_DEAL_DAMAGE_AND_PASS then
		data.heroBehaviour = function(collider, collided, a, v)
			if not collider.damagedGroup[collided] then
				GameRules.GameMode.Round:DealDamage(a, v, true)
				collider.damagedGroup[collided] = true
			end

			return false
		end
	end

	projectile.data = data
	projectile.position = data.from
	projectile.data.initProjectile(projectile)
	projectile.dummy = CreateUnitByName(DUMMY_UNIT, data.from, false, nil, nil, DOTA_TEAM_NOTEAM)
	projectile.effectId = ParticleManager:CreateParticle(data.graphics, PATTACH_ABSORIGIN_FOLLOW , projectile.dummy)
	projectile.UpdatePosition = data.updatePosition
	projectile.Destroy = function(self)
		UTIL_Remove(self.dummy)
		ParticleManager:DestroyParticle(self.effectId, false)
		ParticleManager:ReleaseParticleIndex(self.effectId)
	end
	
	table.insert(Projectiles, projectile)
end

Physics:CreateColliderProfile("defaultCollider", {
	type = COLLIDER_SPHERE,
	skipFrames = 0,
	test = function (table, collider, collided)
		local isDummy = collided.GetUnitName and collided:GetUnitName() == DUMMY_UNIT
		local isHero = collided.IsRealHero and collided:IsRealHero()

		return (isDummy or isHero) and collider.data.owner ~= collided
	end,
	action = function (table, collider, collided)
		local isHero = collided.IsRealHero and collided:IsRealHero()

		if isHero then
			local attacker = collider.data.owner.playerData
			local victim = collided.playerData

			if collider.data.heroBehaviour(collider, collided, attacker, victim) then
				DestroyProjectile(collider)
			end
		end

		if collided.GetUnitName and collided:GetUnitName() == DUMMY_UNIT then
			DestroyProjectile(collider)
			DestroyProjectile(collided)
		end
	end
})
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
	local someoneWasHurt = false

	if attacker == nil then
		return false
	end

	for _, player in pairs(round.Players) do
		if condition(attacker, player) then
			round:DealDamage(attacker, player, false)
			someoneWasHurt = true
		end
	end

	if someoneWasHurt then
		round:CheckEndConditions()
	end

	return someoneWasHurt
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