-- Thanks to Создатель for helping with creation of this skill!

LinkLuaModifier("modifier_void_r", "abilities/void/modifier_void_r", LUA_MODIFIER_MOTION_NONE)

void_r = class({})

function void_r:OnChannelThink(interval)

    self.channelingTime = (self.channelingTime or 0) + interval
    self.shots = self.shots or 0
    local hero = self:GetCaster():GetParentEntity()
    local mod = hero:FindModifier("modifier_void_r")

    --print('start ->')
    --print(GameRules:GetGameTime())

    if not mod then
    	hero:AddNewModifier(hero, self, "modifier_void_r", { duration = 0.6 })
    end

    if self.shots * 0.6 + 0.3 <= self.channelingTime then
    	self.shots = self.shots + 1
    	local target = self:GetCursorPosition()

    	CreateEntityAOEMarker(target + Vector(0,0,32), 250,(Vector(0,0,2000) - self:GetDirection()*2000):Length2D() / 3500 + 0.2, { 178,24,186 }, 0.6, true)
    	ArcProjectile(self.round, {
	        ability = self,
	        owner = hero,
	        from = target + Vector(0, 0, 3000) - self:GetDirection() * 2000,
	        to = target,
	        speed = 3500,
	        arc = 200,
	        radius = 96,
	        graphics = "particles/void_r/void_r.vpcf",
	        hitSound = "Arena.Invoker.HitR",
	        hitFunction = function(projectile, hit)
	            --print('end ->')
    			--print(GameRules:GetGameTime())
	            local particle = ParticleManager:CreateParticle("particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	            ParticleManager:SetParticleControl(particle, 3, target)
	            ParticleManager:ReleaseParticleIndex(particle)

	            Spells:GroundDamage(target, 250, hero, true)
	            Spells:GroundDamage(target, 250, hero, true)

	            ScreenShake(target, 5, 150, 0.5, 4000, 0, true)

	            hero:AreaEffect({
			        ability = self,
			        filter = Filters.Area(target, 250),
			        damage = self:GetDamage()
			    })
	        end,
	        loopingSound = "Arena.Invoker.LoopR"
	    }):Activate()
		AddAnimationTranslate(hero:GetUnit(), "ti7", 0.1)
		hero:Animate(ACT_DOTA_CAST_ABILITY_2, 1.5)
    end
end

function void_r:OnChannelFinish()
  	self.channelingTime = nil
  	self.shots = 0
end

function void_r:GetChannelTime()
    return 2.25
end

function void_r:GetPlaybackRateOverride()
    return 0.9
end

function void_r:GetCastAnimation()
	return ACT_DOTA_GENERIC_CHANNEL_1
end

if IsServer() then
    Wrappers.GuidedAbility(void_r, true)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(void_r)