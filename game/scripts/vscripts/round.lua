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

    self.SpawnPoints = {}

    for i = 0, 3 do
        table.insert(self.SpawnPoints, "spawn"..i)
    end
end

function Round:CreateStages()
    self.Stages = {}

    -- TODO remove corpses if out of the map when layer changes
    table.insert(self.Stages, Stage("StageIslandFirst", FIRST_CRUMBLE_TIME * 10,
        function()
            self.Level:SwapLayers("InfoLayer1", "InfoLayer2")
            self.Level:EnableObstructors(Entities:FindAllByName(SECOND_STAGE_OBSTRUCTOR), true)
        end,

        function(stage)
            if stage.remaining == 50 then
                EmitAnnouncerSound("announcer_ann_custom_timer_sec_05")
            end

            if stage.remaining == 100 then
                EmitAnnouncerSound("announcer_ann_custom_weather_alert_19") -- Earthquake
            end
        end
    ))

    table.insert(self.Stages, Stage("StageIslandSecond", SECOND_CRUMBLE_TIME * 10,
        function()
            self.Level:SwapLayers("InfoLayer2", "InfoLayer3")
            self.Level:EnableObstructors(Entities:FindAllByName(THIRD_STAGE_OBSTRUCTOR), true)
        end,

        function(stage)
            if stage.remaining == 50 then
                EmitAnnouncerSound("announcer_ann_custom_timer_sec_05")
            end

            if stage.remaining == 100 then
                EmitAnnouncerSound("announcer_ann_custom_weather_alert_23") -- Landslide
            end
        end
    ))

    table.insert(self.Stages, Stage("StageSuddenDeath", SUDDEN_DEATH_TIME * 10))

    table.insert(self.Stages, Stage("StageFinal", -1, 
        function()
            EmitAnnouncerSound("announcer_ann_custom_sudden_death")
        end,

        function(stage)
            if stage.remaining % 10 == 0 then
                for _, player in pairs(self.Players) do
                    player.hero:Damage()
                end

                self:CheckEndConditions()
            end
        end
    ))
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

function Round:Update()
    local stage = self.Stages[self.Stage]

    if stage.duration == -1 and stage.remaining == -1 and stage.callback then
        stage.callback()
    end

    stage.remaining = stage.remaining - 1

    if stage.update then
        stage.update(stage)
    end

    self:UpdateTimer()

    if stage.remaining == 0 then
        if stage.callback then
            stage.callback()
        end

        if stage.duration ~= -1 then
            self.Stage = self.Stage + 1
        end
    end
end

function Round:UpdateFalling()
    local someoneDied = false

    for _, player in pairs(self.Players) do
        local hero = player.hero

        if hero then
            hero:Update()

            if not hero.falling then
                if self.Level:TestOutOfMap(hero, self.Stage) then
                    hero:StartFalling()
                end
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
    Shuffle(self.SpawnPoints)

    local index = 1

    for i, player in pairs(self.Players) do
        local oldHero = player.hero

        if player:IsConnected() then
            local spawnIndex = index
            
            PrecacheUnitByNameAsync(player.selectedHero,
                function ()
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

                    local spawnPoint = Entities:FindAllByName(self.SpawnPoints[spawnIndex])[1]
                    hero:SetPos(spawnPoint:GetAbsOrigin())

                    unit:FindAbilityByName(ultimate):StartCooldown(ULTS_TIME)

                    MoveCameraToUnit(player.id, unit)

                    player.hero = hero
                end
            )

            index = index + 1
        else
            player.hero = nil
            
            if oldHero then
                oldHero:Delete()
            end
        end
    end
end

function Round:UpdateTimer()
    CustomNetTables:SetTableValue("main", "timer", self.Stages[self.Stage]);
end

function Round:Reset()
    if self.Stage == 2 then
        self.Level:SwapLayers("InfoLayer2", "InfoLayer1")
    end

    if self.Stage >= 3 then
        self.Level:SwapLayers("InfoLayer3", "InfoLayer1")
    end

    self.Stage = 1
    self.Level:EnableObstructors(Entities:FindAllByClassname("point_simple_obstruction"), false)

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

    self:CreateStages()
    self:UpdateTimer()
end