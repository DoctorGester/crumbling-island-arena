cm_e_sub = class({})

function cm_e_sub:OnSpellStart()
    local hero = self:GetCaster().hero
    local icePath = hero:FindAbility("cm_e").icePath

    if icePath then
        local particle = "particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf"
        local deathSim = SpawnEntityFromTableSynchronous("prop_dynamic", {
            origin = hero:GetPos(),
            model = "models/heroes/crystal_maiden/crystal_maiden_deathsim.vmdl",
            DefaultAnim = "crystal_maiden_deathsim1_anim"
        })
        deathSim:SetForwardVector(hero:GetFacing())
        ImmediateEffectPoint(particle, PATTACH_CUSTOMORIGIN, hero, hero:GetPos())
        TimedEntity(5, function() deathSim:RemoveSelf() end):Activate()

        hero:FindClearSpace(icePath:GetPos(), true)
        hero:EmitSound("Arena.CM.CastSubE")
        icePath:Destroy()
        ImmediateEffectPoint(particle, PATTACH_CUSTOMORIGIN, hero, hero:GetPos())
    end
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(cm_e_sub)
