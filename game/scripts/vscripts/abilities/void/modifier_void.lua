modifier_void = class ({})
local self = modifier_void

self.tableHP = {}

function self:IsHidden()
	return true
end

if IsServer() then
	function self:OnCreated()
		self:StartIntervalThink(0.1)
		self:OnIntervalThink()
	end

	function self:OnIntervalThink()
		local hero = self:GetCaster():GetParentEntity()

		local HP = hero:GetHealth()
		local tableLength = #self.tableHP

		if tableLength > 20 then
			table.remove(self.tableHP, 1)
		end

		table.insert(self.tableHP, HP)
	end
end

function self:TimeWalkHP()
	return self.tableHP[1]
end

