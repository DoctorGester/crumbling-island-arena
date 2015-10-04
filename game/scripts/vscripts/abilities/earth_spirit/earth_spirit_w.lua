earth_spirit_w = class({})

function earth_spirit_w:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()

	--dofile("abilities/earth_spirit/testfile")
	require("abilities/earth_spirit/testfile")
	local cl = "Test"
	local code = assert(loadstring("return "..cl.."()"))
	local instance = code()
	print(instance.mom)


end