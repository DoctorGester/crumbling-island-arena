Jugger = class({}, {}, Hero)

LinkLuaModifier("modifier_jugger_sword", "abilities/jugger/modifier_jugger_sword", LUA_MODIFIER_MOTION_NONE)

Jugger.Swords = {
    [0] = { range = 250, model = "models/heroes/juggernaut/jugg_sword.vmdl" },
    [1] = { range = 500, model = "models/items/juggernaut/generic_wep_broadsword.vmdl", particle = "particles/jugger_sword/jugger_sword_1_glow.vpcf" },
    [2] = { range = 800, model = "models/items/juggernaut/generic_wep_solidsword.vmdl", particle = "particles/jugger_sword/jugger_sword_2_glow.vpcf" },
    [3] = { range = 1300, model = "models/items/juggernaut/generic_sword_nodachi.vmdl", particle = "particles/jugger_sword/jugger_sword_3_glow.vpcf" },
    [4] = { range = 1600, model = "models/items/juggernaut/dragon_sword.vmdl", particle = "particles/jugger_sword/jugger_sword_4_glow.vpcf" }
}

function Jugger:SetUnit(unit)
    getbase(Jugger).SetUnit(self, unit)

    self.swordLevel = 0
    self:AddNewModifier(self, nil, "modifier_jugger_sword", {})
    self:UpdateSwordLevel()
    self:StartSwordTimer()

    self.swordOnLevel = nil
end

function Jugger:SwordPickedUp()
    self.swordOnLevel = nil
    self.swordLevel = self.swordLevel + 1
    self:UpdateSwordLevel()
    ImmediateEffect("particles/econ/events/ti6/hero_levelup_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
end

function Jugger:UseUltiCharge()
    self.swordLevel = self.swordLevel - 1
    self:FindAbility("jugger_q"):EndCooldown()
    self:UpdateSwordLevel()

    if self.swordLevel == 0 then
        self:FindModifier("modifier_jugger_r"):Destroy()
    end
end

function Jugger:UpdateSwordLevel()
    self:FindModifier("modifier_jugger_sword"):SetStackCount(Jugger.Swords[self.swordLevel].range)

    local wearable = self:GetUnit():FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            if string.find(wearable:GetModelName(), "sword") then
                wearable:SetModel(Jugger.Swords[self.swordLevel].model)
                return
            end
        end

        wearable = wearable:NextMovePeer()
    end
end

function Jugger:GetSwordRange()
    return self:FindModifier("modifier_jugger_sword"):GetStackCount()
end

function Jugger:StartSwordTimer()
    self:FindModifier("modifier_jugger_sword"):SetDuration(16, true)
end

function Jugger:FindSpaceToSpawn()
    local parts = {}

    GameRules.GameMode.level:GroundAction(
        function(part)
            local distance = (self:GetPos() - Vector(part.x, part.y, 0)):Length2D()
            if distance > 600 and distance < 2200 and Vector(part.x, part.y, 0):Length2D() < 1600 then
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