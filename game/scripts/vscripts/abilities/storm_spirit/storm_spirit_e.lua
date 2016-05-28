storm_spirit_e = class({})
LinkLuaModifier("modifier_storm_spirit_e", "abilities/storm_spirit/modifier_storm_spirit_e", LUA_MODIFIER_MOTION_NONE)

function storm_spirit_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local remnant = hero:FindClosestRemnant(target)

    if remnant then
        hero:EmitSound("Arena.Storm.CastE")

        Dash(hero, remnant:GetPos(), 1200, {
            modifier = { name = "modifier_storm_spirit_e", ability = self },
            forceFacing = true,
            loopingSound = "Arena.Storm.LoopE",
            arrivalFunction = function(dash) remnant:Destroy() end
        })
    end
end

function storm_spirit_e:CastFilterResultLocation(location)
    -- Remnant data can't be accessed on the client
    if not IsServer() then return UF_SUCCESS end

    if not self:GetCaster().hero:HasRemnants() then
        return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
end

function storm_spirit_e:GetCustomCastErrorLocation(location)
    if not IsServer() then return "" end

    if not self:GetCaster().hero:HasRemnants() then
        return "#dota_hud_error_cant_cast_no_remnants"
    end

    return ""
end