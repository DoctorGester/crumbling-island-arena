GRACE_TIME = 1.5
ULTS_TIME = 40

Round = Round or class({})

function Round:constructor(players, teams, availableHeroes, callback)
    self.winner = nil
    self.ended = false
    self.entityDied = false
    self.callback = callback

    self.players = players
    self.teams = teams
    self.availableHeroes = availableHeroes

    self.isTryingToEnd = false
    self.timeRemainingUntilEnd = 0

    self.spells = Spells()
    self.statistics = Statistics(players)
    self.runeTimer = 25 * 30

    self.runeParticleParams = {"particles/rune_marker.vpcf", PATTACH_ABSORIGIN, GameRules:GetGameModeEntity(), {
        cp0 = Vector(0, 0, 32),
        cp1 = Vector(200, 0, 0),
        release = false
    }}

    self.rune = nil
    self.runeParticle = FX(unpack(self.runeParticleParams))
end

function Round:GetLastOrNoneAlive()
    local teams = {}

    for _, player in pairs(self.players) do
        if player:IsConnected() and (player.hero and not player.hero.unit:IsNull() and player.hero:Alive()) then
            teams[player.team] = true
        end
    end

    local amountAlive = 0
    local lastAlive

    for team, _ in pairs(teams) do
        amountAlive = amountAlive + 1
        lastAlive = team
    end

    return lastAlive, amountAlive
end

function Round:IsAnyoneFalling()
    for _, player in pairs(self.players) do
        if player:IsConnected() and (player.hero and not player.hero.unit:IsNull() and player.hero:Alive()) and player.hero.falling then
            return true
        end
    end

    return false
end

function Round:CheckEndConditions()
    if self.ended then
        return
    end

    local lastAlive, amountAlive = self:GetLastOrNoneAlive()
    return amountAlive <= 1
end

function Round:EndRound()
    for _, player in pairs(self.players) do
        if player.hero then
            player.hero.protected = true
        end
    end

    self.isTryingToEnd = false
    self.ended = true
    self:callback()
end

function Round:Update()
    self.spells:Update()

    if not self.ended then
        if not self.rune then
            self.runeTimer = self.runeTimer - 1

            if self.runeTimer <= 0 then
                self.rune = Rune(self):Activate()
            end
        end

        if self.rune and not self.rune:Alive() then
            if self.runeParticle then
                ParticleManager:DestroyParticle(self.runeParticle, false)
                ParticleManager:ReleaseParticleIndex(self.runeParticle)

                self.runeParticle = nil
            end

            self.rune = nil
            self.runeTimer = 25 * 30
            self.runeParticle = FX(unpack(self.runeParticleParams))
        end
    end

    -- End conditions and stuff under there
    if self.ended then
        return
    end

    if self.isTryingToEnd then
        if not self:IsAnyoneFalling() then
            self.timeRemainingUntilEnd = self.timeRemainingUntilEnd - FrameTime()
        end

        if self.timeRemainingUntilEnd <= 0 then
            local lastAlive, amountAlive = self:GetLastOrNoneAlive()

            self.winner = lastAlive
            self:EndRound()
        end
    end

    if self.entityDied then
        self.entityDied = false

        if self:CheckEndConditions() then
            self.isTryingToEnd = true
            self.timeRemainingUntilEnd = GRACE_TIME
        end
    end
end

function Round:LoadHeroClass(name)
    local classValue = self.availableHeroes[name].class

    if classValue then
        local path, className = classValue:match("([^:]+):([^:]+)")
        print("Loading class "..classValue)
        require(path)

        return _G[className](self.availableHeroes[name])
    else
        print("Falling back to default Hero class")

        return Hero(self.availableHeroes[name])
    end
end

function Round:LoadHeroMixins(name, hero)
    local defaultMixin = self.availableHeroes[name].defaultMixin

    if defaultMixin then
        local path, className = defaultMixin:match("([^:]+):([^:]+)")
        print("Loading mixin "..defaultMixin)
        require(path)

        hero:AddMixin(_G[className]())
    end

    return hero
end

function Round:GetTeamInverted(team)
    local inverted = {}

    for key, value in pairs(self.teams) do
        if value == team then
            return key
        end
    end

    return -1
end

function Round:SpawnObstacles()
    local mdls = {
        "models/props_stone/column/colosseum_column001.vmdl",
        "models/props_stone/column/colosseum_column001a.vmdl",
        "models/props_stone/column/colosseum_column002.vmdl"
    }

    local bigMap = GetMapName() == "unranked" or GetMapName() == "ranked_3v3"

    --if bigMap then
    mdls = {
        "models/props_tree/cypress/tree_cypress010.vmdl",
        "models/props_tree/cypress/tree_cypress008.vmdl"
    }
    --end

    for i = 0, 3 do
        local centerAngle = math.pi / 2 * i + math.pi / 4

        for j = -4, 4 do
            local outside = math.abs(j) > 1
            local range = 800
            local anMul = 0.15

            if outside then
                range = 1800
                anMul = 0.06
            end

            if not outside or bigMap and math.abs(j) ~= 2 then
                local an = centerAngle + anMul * j
                local pos = Vector(math.cos(an), math.sin(an), 0) * (range - math.abs(j) * 30)
                local ent = Obstacle(mdls[RandomInt(1, #mdls)], pos)

                ent:Activate()

                --if bigMap then
                ent:SetRenderColor(80 + RandomInt(-10, 10), 90 + RandomInt(-10, 10), 30)
                --end
            end
        end
    end
end

function Round:CreateHeroes(spawnPoints, isRanked)
    print("Creating heroes")
    if not isRanked then
        Shuffle(spawnPoints)
    end

    local teamSpawned = {}

    local teams = {}
    for i, player in pairs(self.players) do
        teams[player.team] = true
    end

    local teamCount = 0
    for _, _ in pairs(teams) do
        teamCount = teamCount + 1
    end

    local totalSpawns = #spawnPoints
    local spawnOffset = RandomInt(0, totalSpawns)

    for i, player in pairs(self.players) do
        if player:IsConnected() and player.selectionLocked and player.selectedHero ~= nil then
            local pointIndex = self:GetTeamInverted(player.team) + 1

            if isRanked then
                pointIndex = (self:GetTeamInverted(player.team) * math.floor(totalSpawns / teamCount) + spawnOffset) % totalSpawns + 1
            end

            local offset = (teamSpawned[player.team] or 0)
            local hero = self:LoadHeroClass(player.selectedHero)
            local unit = CreateUnitByName(player.selectedHero, spawnPoints[pointIndex] + Vector(0, 128, 0) * offset, true, nil, nil, player.team)
            hero:SetUnit(unit)
            hero:SetFacing(-hero:GetPos())

            hero:Setup()
            hero:SetOwner(player)

            self:LoadHeroMixins(player.selectedHero, hero)

            local count = unit:GetAbilityCount() - 1
            for i = 0, count do
                local ability = unit:GetAbilityByIndex(i)

                if ability ~= nil then
                    if string.ends(ability:GetName(), "_r") then
                        ability:StartCooldown(self.availableHeroes[player.selectedHero].initialCD or ULTS_TIME)
                    else
                        ability:StartCooldown(3)
                    end
                end
            end

            hero:Activate()

            self.statistics:AddPlayedHero(player, player.selectedHero)

            player.hero = hero

            teamSpawned[player.team] = offset + 1
        else
            player.hero = nil
        end
    end
end

function Round:Destroy()
    local loops = 0

    while #self.spells.entities > 0 do
        for _, player in pairs(self.players) do
            if player.hero then
                self.spells:InterruptDashes(player.hero)
                player.hero:Hide()
            end
        end

        self:Update() -- To stop dashes

        for _, entity in pairs(self.spells.entities) do
            if instanceof(entity, Hero) then
                entity.removeOnDeath = true
            end

            entity:Destroy()
        end

        self:Update()

        loops = loops + 1

        if loops > 50 then
            print("Round:Destroy looped 100 times, aborting")
            break
        end
    end

    if self.runeParticle then
        ParticleManager:DestroyParticle(self.runeParticle, false)
        ParticleManager:ReleaseParticleIndex(self.runeParticle)
    end
end