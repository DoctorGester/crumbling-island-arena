slark_a = class({})

LinkLuaModifier("modifier_slark_a", "abilities/slark/modifier_slark_a", LUA_MODIFIER_MOTION_NONE)

function slark_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:EmitSound("Arena.Slark.PreA")

    return true
end

function slark_a:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local damage = self:GetDamage()
    local force = 20

    hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, 300, forward, math.pi),
        sound = "Arena.Slark.HitA",
        damage = damage,
        knockback = { force = force, decrease = 3 },
        isPhysical = true,
        action = function(target)
            if instanceof(target, Hero) then
                FX("particles/units/heroes/hero_slark/slark_essence_shift.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, {
                    cp0 = { ent = target, point = "attach_hitloc" },
                    cp1 = { ent = hero, point = "attach_hitloc" },
                    release = true
                })
                local targetMod
                local heroMod

                for _,modifier in pairs(target:AllModifiers()) do
                    if modifier:GetName() == "modifier_slark_a" and modifier:GetAbility():GetCaster() == self:GetCaster() then
                        modifier:AddNewStack()
                        targetMod = modifier
                        break
                    end
                end
                for _,modifier in pairs(hero:AllModifiers()) do
                    if modifier:GetName() == "modifier_slark_a" and modifier:GetAbility():GetCaster() == self:GetCaster() then
                        modifier:AddNewStack(target)
                        heroMod = modifier
                        break
                    end
                end

                if not targetMod and target:Alive() then
                    target:AddNewModifier(hero, self, "modifier_slark_a", { duration = 12 }):AddNewStack()
                end
                if not heroMod then
                    hero:AddNewModifier(hero, self, "modifier_slark_a", { duration = 12 }):AddNewStack(target)
                end
            end
        end
    })
end

function slark_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function slark_a:GetPlaybackRateOverride()
    return 4
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(slark_a, nil, "particles/melee_attack_blur.vpcf")