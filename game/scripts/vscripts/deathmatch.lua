DeathMatch = DeathMatch or class({})

function DeathMatch:constructor(players, availableHeroes) 
    CustomGameEventManager:RegisterListener("dm_respawn", function(id, ...) self["OnRespawn"](self, ...) end)
    CustomGameEventManager:RegisterListener("dm_random", function(id, ...) self["OnRandom"](self, ...) end)

    self.deathMatchLockTime = 180
    self.players = players
    self.availableHeroes = availableHeroes
    self.removalQueue = {}
end

function DeathMatch:Update()
    self.deathMatchLockTime = self.deathMatchLockTime - 1

    if self.deathMatchLockTime == 0 then
        GameRules.GameMode:UpdatePlayerTable()
    end

    local time = GameRules:GetGameTime()

    for hero, timeQueued in pairs(self.removalQueue) do
        if time - timeQueued >= 10 then
            hero.removeOnDeath = true
            hero:Destroy()
            self.removalQueue[hero] = nil
        end
    end
end

function DeathMatch:SendKillMessageToTeam(team, victim)
    CustomGameEventManager:Send_ServerToTeam(team, "kill_message", { victim = victim, token = "KMNormal" })
end

function DeathMatch:SendFirstBloodMessage(victim)
    CustomGameEventManager:Send_ServerToAllClients("kill_message", { victim = victim, token = "KMFirstBlood", sound = "UI.FirstBlood" })
end

function DeathMatch:OnRespawn(args)
    local player = self.players[args.PlayerID]
    local hero = args.hero

    if player.hero and not player.hero:Alive() then
        local heroData = self.availableHeroes[hero]

        if not heroData or (self:AreHardHeroesLocked() and heroData.difficulty == "hard") then
            return
        end

        self:CreateHeroForPlayer(player, hero)
    end
end

function DeathMatch:EnqueueRemove(hero)
    self.removalQueue[hero] = GameRules:GetGameTime()
end

function DeathMatch:AreHardHeroesLocked()
    if self.deathMatchLockTime == nil then
        return true
    end

    return self.deathMatchLockTime > 0
end

function DeathMatch:FindPlaceToRespawn()
    local maxDistance = -1
    local farthestPart = nil

    GameRules.GameMode.level:GroundAction(
        function(part)
            local pos = Vector(part.x, part.y, 0)
            if pos:Length2D() < GameRules.GameMode.level.distance - 700 then
                local distance = 0
                for _, player in pairs(self.players) do
                    if player.hero and player.hero:Alive() then
                        distance = distance + (player.hero:GetPos() - pos):Length2D()
                    end
                end

                if distance > maxDistance then
                    maxDistance = distance
                    farthestPart = part
                end
            end
        end
    )

    if farthestPart then
        return Vector(farthestPart.x + farthestPart.offsetX, farthestPart.y + farthestPart.offsetY)
    end
end

function DeathMatch:CreateHeroForPlayer(player, heroName)
    local position = self:FindPlaceToRespawn()

    if not position then
        return
    end

    local hero = GameRules.GameMode.round:LoadHeroClass(heroName)
    local unit = CreateUnitByName(heroName, position, true, nil, nil, player.team)
    hero:SetUnit(unit)
    hero:Setup()
    hero:SetOwner(player)

    local count = unit:GetAbilityCount() - 1
    for i = 0, count do
        local ability = unit:GetAbilityByIndex(i)

        if ability ~= nil and string.ends(ability:GetName(), "_r") then
            local initialCooldown = self.availableHeroes[player.selectedHero].initialCD
            local actualCooldown = ability:GetCooldown(1) * 1.5

            if actualCooldown < 10 then
                actualCooldown = ULTS_TIME / 2
            end

            ability:StartCooldown(initialCooldown or actualCooldown)
        end
    end

    hero:Activate()
    player.hero = hero
    player.selectedHero = heroName

    FX("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, { release = true })

    GameRules.GameMode:UpdatePlayerTable()
    GameRules.GameMode.round.statistics:AddPlayedHero(player, player.selectedHero)

    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(player.id), "dm_respawn_event", { x = position.x, y = position.y })
end

function DeathMatch:OnRandom(args)
    local player = self.players[args.PlayerID]

    if player.hero and not player.hero:Alive() then
        local allHeroes = {}

        for hero, data in pairs(self.availableHeroes) do
            if not self:AreHardHeroesLocked() or data.difficulty ~= "hard" then
                table.insert(allHeroes, hero)
            end
        end

        self:CreateHeroForPlayer(player, allHeroes[RandomInt(1, #allHeroes)])
    end
end

function DeathMatch:CleanupPlayer(round, player)
    self:EnqueueRemove(player.hero)

    if player.hero then
        round.spells:InterruptDashes(player.hero)
    end

    for _, entity in pairs(round.spells.entities) do
        if entity.owner == player then
            if not instanceof(entity, Projectile) and not instanceof(entity, ArcProjectile) and not instanceof(entity, Hero) then
                entity:Destroy()
            end
        end
    end
end

function DeathMatch:OnRoundEnd(round)
    GameRules.GameMode.generalStatistics:Add(round.statistics)
    GameRules.GameMode:EndGame()
end

function DeathMatch:Activate(GameMode, inst)
    function GameMode:OnEntityKilled(event)
        local entity = EntIndexToHScript(event.entindex_killed)

        if entity:IsHero() and entity.hero then
            PlayerResource:SetOverrideSelectionEntity(entity.hero.owner.id, nil)

            if entity:GetAbsOrigin().z <= -MAP_HEIGHT then
                local lastKnockbackCaster = entity.hero.lastKnockbackCaster
                lastKnockbackCaster = lastKnockbackCaster or self.level:FindReasonForFalling(entity.hero)

                self:RecordKill(entity.hero, lastKnockbackCaster or entity.hero, true)
            end
        end
    end

    function GameMode:RecordKill(victim, source, fell)
        if victim.owner.team ~= source.owner.team then
            self.round.statistics:IncreaseKills(source.owner)

            if not self.firstBloodBy then
                self.firstBloodBy = source
                self.round.statistics:IncreaseFBs(source.owner)
                self.deathmatch:SendFirstBloodMessage(victim:GetName())
            else
                self.deathmatch:SendKillMessageToTeam(source.owner.team, victim:GetName())
            end

            source.owner.score = source.owner.score + 1

            if source.owner.score >= self.gameGoal then
                self.winner = source.owner.team
                self.round:EndRound()
            end
        end

        if not fell then
            FX("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_ABSORIGIN, source, {
                cp4 = victim:GetPos(),
                release = true
            })
        end

        self.deathmatch:CleanupPlayer(self.round, victim.owner)

        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(victim.owner.id), "dm_death_event", {})

        self:UpdatePlayerTable()

        CustomGameEventManager:Send_ServerToAllClients("kill_log_entry", {
            killer = source.owner.hero:GetName(),
            victim = victim:GetName(),
            color = self.TeamColors[source.owner.team],
            fell = fell
        })
    end

    function GameMode:UpdatePlayerTable()
        local players = {}

        for i, player in pairs(self.Players) do
            local playerData = {}
            playerData.id = i
            playerData.hero = player.selectedHero
            playerData.team = player.team
            playerData.color = self.TeamColors[player.team]
            playerData.score = player.score

            if player.hero then
                playerData.isDead = not player.hero:Alive()
            end

            table.insert(players, playerData)
        end

        CustomNetTables:SetTableValue("main", "players", {
            players = players,
            goal = self.gameGoal,
            isDeathMatch = self:IsDeathMatch(),
            deathMatchHeroesLocked = self.deathmatch:AreHardHeroesLocked()
        })
    end
end