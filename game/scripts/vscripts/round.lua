GRACE_TIME = 1
FIRST_CRUMBLE_TIME = 50
SECOND_CRUMBLE_TIME = 30
SUDDEN_DEATH_TIME = 40
ULTS_TIME = 55

if Round == nil then
    Round = class({})
end

function Stage(label, duration, callback, update)
    local self = {}

    self.label = label
    self.duration = duration
    self.remaining = duration
    self.callback = callback
    self.update = update
    
    return self
end

function Round:constructor(level, players, gameItems, availableHeroes)
    self.Stage = 1
    self.Winner = nil
    self.Ended = false

    self.Level = level
    self.Players = players
    self.GameItems = gameItems
    self.AvailableHeroes = availableHeroes
end

function Round:GetAllHeroes()
    local result = {}

    for _, player in pairs(self.Players) do
        if player.hero then
            table.insert(result, player.hero)
        end
    end

    return result
end

function Round:CheckEndConditions()
    local amountAlive = 0
    local lastAlive = nil

    if self.Ended then
        return
    end

    for _, player in pairs(self.Players) do
        if player.hero:Alive() then
            amountAlive = amountAlive + 1
            lastAlive = player
        end
    end

    if amountAlive == 0 then
        self.Winner = nil
        self:EndRound()
    end

    if amountAlive == 1 then
        self.Winner = lastAlive
        self:EndRound()
    end
end

function Round:EndRound()
    for _, player in pairs(self.Players) do
        player.hero.protected = true
    end

    self.Ended = true

    EmitAnnouncerSound("announcer_ann_custom_round_complete")

    Timers:CreateTimer(GRACE_TIME, function()
        self.Callback()
    end)
end

function Round:UpdateFalling()
    local someoneDied = false

    for _, player in pairs(self.Players) do
        local hero = player.hero

        if hero then
            hero:Update()

            if not hero.falling then
                --if self.Level:TestOutOfMap(hero, self.Stage) then
                    --hero:StartFalling()
                --end
            else
                local result = hero:UpdateFalling()

                if result then
                    someoneDied = true
                end
            end
        end
    end

    if someoneDied then
        self:CheckEndConditions()
    end
end

function Round:LoadHeroClass(name)
    local classValue = self.AvailableHeroes[name].class

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

    for i, player in pairs(self.Players) do
        local oldHero = player.hero

        if player:IsConnected() then
            local hero = self:LoadHeroClass(player.selectedHero)
            local unit = CreateUnitByName(player.selectedHero, Vector(0, 0, 0), true, nil, nil, player.team)
            hero:SetUnit(unit)

            if oldHero then
                oldHero:Delete()
            end

            --LoadDefaultHeroItems(player.hero, self.GameItems)
            local ultimate = self.AvailableHeroes[hero:GetName()].ultimate
            hero:Setup()
            hero:SetOwner(player)
            hero:SetPos(spawnPoints[index])

            unit:FindAbilityByName(ultimate):StartCooldown(ULTS_TIME)

            MoveCameraToUnit(player.id, unit)

            player.hero = hero

            index = index + 1
        else
            player.hero = nil
            
            if oldHero then
                oldHero:Delete()
            end
        end
    end
end

function Round:Reset()
    GridNav:RegrowAllTrees()

    for _, projectile in pairs(Projectiles) do
        projectile:Destroy()
    end

    for _, player in pairs(self.Players) do
        if player.hero then
            player.hero:Hide()
        end
    end
end

function Round:Start(callback)
    self.Stage = 1
    self.Callback = callback
    self.Ended = false
end