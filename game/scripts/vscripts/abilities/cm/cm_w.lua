cm_w = class({})

function cm_w:OnSpellStart()
	local hero = self:GetCaster().hero
	local startPos = self:GetInitialPosition()
    local endPos = startPos + self:GetDirectionVector() * 400
end

function cm_w:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end