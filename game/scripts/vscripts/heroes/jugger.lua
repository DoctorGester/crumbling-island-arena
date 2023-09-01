Jugger = class({}, {}, Hero)

Jugger.Swords = {
    [0] = {
        range = 250,
        model = "models/heroes/juggernaut/jugg_sword.vmdl",
        attackParticle = "particles/jugger_q/jugger_q.vpcf"
    },

    [1] = {
        range = 500,
        model = "models/items/juggernaut/generic_wep_broadsword.vmdl",
        particle = "particles/jugger_sword/jugger_sword_1_glow.vpcf",
        swordParticle = "particles/jugger_sword/jugger_sword_1_glow_blade.vpcf",
        attackParticle = "particles/jugger_q/jugger_q_sword_1.vpcf"
    },

    [2] = { 
        range = 800,
        model = "models/items/juggernaut/generic_wep_solidsword.vmdl",
        particle = "particles/jugger_sword/jugger_sword_2_glow.vpcf",
        swordParticle = "particles/jugger_sword/jugger_sword_2_glow_blade.vpcf",
        attackParticle = "particles/jugger_q/jugger_q_sword_2.vpcf"
    },

    [3] = {
        range = 1300,
        model = "models/items/juggernaut/generic_sword_nodachi.vmdl",
        particle = "particles/jugger_sword/jugger_sword_3_glow.vpcf",
        swordParticle = "particles/jugger_sword/jugger_sword_3_glow_blade.vpcf",
        attackParticle = "particles/jugger_q/jugger_q_sword_3.vpcf"
    },

    [4] = {
        range = 1600,
        model = "models/items/juggernaut/dragon_sword.vmdl",
        particle = "particles/jugger_sword/jugger_sword_4_glow.vpcf",
        swordParticle = "particles/jugger_sword/jugger_sword_4_glow_blade.vpcf",
        attackParticle = "particles/jugger_q/jugger_q_sword_4.vpcf"
    }
}

function Jugger:SetOwner(owner)
    getbase(Jugger).SetOwner(self, owner)

    self.swordModel = self:AttachWearable(self:GetSwordModel(0))
    self.swordLevel = 0
    self:AddNewModifier(self, nil, "modifier_jugger_sword", {})
    self:UpdateSwordLevel()
    self:StartSwordTimer()

    self.swordOnLevel = nil
    self.swordParticle = nil
end

function Jugger:GetSwordModel(level)
    if level == 0 and self:IsAwardEnabled() then
        return "models/items/juggernaut/dc_weaponupdate/dc_weaponupdate.vmdl"
    end

    return Jugger.Swords[level].model
end

function Jugger:SwordOnLevelDestroyed()
    self.swordOnLevel = nil
end

function Jugger:SwordPickedUp()
    self.swordOnLevel = nil
    self.swordLevel = self.swordLevel + 1
    self:UpdateSwordLevel()
    self:EmitSound("Arena.Jugger.PickVoice")
    ImmediateEffect("particles/econ/events/ti6/hero_levelup_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
end

function Jugger:GetAttackParticle()
    return Jugger.Swords[self.swordLevel].attackParticle
end

function Jugger:UseUltiCharge()
    self.swordLevel = self.swordLevel - 1
    self:FindAbility("jugger_a"):EndCooldown()
    self:UpdateSwordLevel()

    if self.swordLevel == 0 then
        self:FindModifier("modifier_jugger_r"):Destroy()
    end

    if self.swordOnLevel ~= nil then
        self.swordOnLevel:SetParticle(Jugger.Swords[self.swordLevel + 1].particle)
    end
end

function Jugger:UpdateSwordLevel()
    self:FindModifier("modifier_jugger_sword"):SetStackCount(Jugger.Swords[self.swordLevel].range)

    self.swordModel:SetModel(self:GetSwordModel(self.swordLevel))
    
    if self.swordParticle then
        ParticleManager:DestroyParticle(self.swordParticle, false)
        ParticleManager:ReleaseParticleIndex(self.swordParticle)
    end

    if self.swordLevel > 0 then
        self.swordParticle = ParticleManager:CreateParticle(Jugger.Swords[self.swordLevel].swordParticle, PATTACH_POINT_FOLLOW, self:GetUnit())
        ParticleManager:SetParticleControlEnt(self.swordParticle, 0, self:GetUnit(), PATTACH_POINT_FOLLOW, "blade_attachment", self:GetUnit():GetAbsOrigin(), true)
    end
end

function Jugger:GetSwordRange()
    return self:FindModifier("modifier_jugger_sword"):GetStackCount()
end

function Jugger:StartSwordTimer()
    self:FindModifier("modifier_jugger_sword"):SetDuration(10, true)
end

function Jugger:FindSpaceToSpawn()
    local parts = {}
    local ldist = GameRules.GameMode.level.distance
    local min = math.min(ldist - 200, 600)

    GameRules.GameMode.level:GroundAction(
        function(part)
            local distance = (self:GetPos() - Vector(part.x, part.y, 0)):Length2D()
            if distance > min and distance < 2200 and Vector(part.x, part.y, 0):Length2D() < math.max(ldist - 700, 700) then
                table.insert(parts, part)
            end
        end
    )

    local len = #parts

    if len > 0 then
        local part = parts[RandomInt(1, len)]
        return Vector(part.x + part.offsetX, part.y + part.offsetY)
    end
end

function Jugger:Update()
    getbase(Jugger).Update(self)

    if not self:Alive() then
        return
    end 

    local ulti = self:FindAbility("jugger_r")
    ulti:SetActivated(self.swordLevel > 0 or not ulti:IsCooldownReady())

    if self:FindModifier("modifier_jugger_sword"):GetRemainingTime() <= 0 and not self:HasModifier("modifier_jugger_r") and self.swordOnLevel == nil and self.swordLevel < 4 then
        local space = self:FindSpaceToSpawn()

        if space then
            self.swordOnLevel = JuggerSword(self.round, self, space, Jugger.Swords[self.swordLevel + 1].particle)
            self.swordOnLevel:Activate()
        end
    end
end