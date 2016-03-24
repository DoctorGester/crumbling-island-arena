GRACE_TIME = 1
ULTS_TIME = 55

Round = Round or class({})

function Round:constructor(players, availableHeroes, callback)
    self.winner = nil
    self.ended = false
    self.entityDied = false
    self.callback = callback

    self.players = players
    self.availableHeroes = availableHeroes

    self.spells = Spells()
end

function Round:CheckEndConditions()
    local amountAlive = 0
    local lastAlive = nil

    if self.ended then
        return
    end

    for _, player in pairs(self.players) do
        if player.hero:Alive() then
            amountAlive = amountAlive + 1
            lastAlive = player
        end
    end

    if amountAlive <= 1 then
        self.winner = lastAlive
        self:EndRound()
    end
end

function Round:EndRound()
    for _, player in pairs(self.players) do
        player.hero.protected = true
    end

    self.ended = true

    EmitAnnouncerSound("announcer_ann_custom_round_complete")

    Timers:CreateTimer(GRACE_TIME, function()
        self:callback()
    end)
end

function Round:Update()
    local status, err = pcall(
        function(self)
            self.spells:Update()
        end
    , self)

    if not status then
        print(err)
    end

    if self.entityDied then
        self.entityDied = false
        self:CheckEndConditions()
    end
end

function Round:LoadHeroClass(name)
    local classValue = self.availableHeroes[name].class

    if classValue then
        print("Loading class "..classValue)

        local path, className = classValue:match("([^:]+):([^:]+)")
        require(path)
        return assert(loadstring("return "..className.."()"))()
    else
        print("Falling back to default Hero class")

        return Hero()
    end
end

function Round:CreateHeroes()
    print("Creating heroes")
    local spawnPoints = {}

    for i = 0, 9 do
        local a = i * math.pi / 10
        table.insert(spawnPoints, Vector(math.cos(a), math.sin(a), 0) * 1200)
    end

    Shuffle(spawnPoints)

    local index = 1

    for i, player in pairs(self.players) do
        if player:IsConnected() then
            local hero = self:LoadHeroClass(player.selectedHero)
            local unit = CreateUnitByName(player.selectedHero, Vector(0, 0, 0), true, nil, nil, player.team)
            hero:SetUnit(unit)

            local ultimate = self.availableHeroes[hero:GetName()].ultimate
            hero:Setup()
            hero:SetOwner(player)
            hero:SetPos(spawnPoints[index])

            unit:FindAbilityByName(ultimate):StartCooldown(ULTS_TIME)

            hero:Activate()

            MoveCameraToUnit(player.id, unit)

            player.hero = hero

            index = index + 1
        else
            player.hero = nil
        end
    end
end

function Round:Destroy()
    for _, player in pairs(self.players) do
        if player.hero then
            player.hero:Hide()
        end
    end

    for _, entity in pairs(self.spells.entities) do
        entity:Destroy()
    end

    self:Update()
end