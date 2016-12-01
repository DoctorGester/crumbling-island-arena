var allHeroes = {};
var playerColors = {};
var selectedHeroes = {};
var previewSchedule = 0;
var hidingCurrentPreview = null;
var playerConnectionStates = {};
var heroPreviews = {};
var heroAwards = {};
var showAllHeroes = false;
var heroSelectionAggregator = undefined;

var previewLoadingQueue = [];

var seasonAwards = {
    0: "npc_dota_hero_lycan",
    1: "npc_dota_hero_juggernaut",
    2: "npc_dota_hero_invoker",
    3: "npc_dota_hero_vengefulspirit",
    4: "npc_dota_hero_zuus",
    5: "npc_dota_hero_ember_spirit"
};

function PreloadPreview(hero, value, insertFirst) {
    var preview = $.CreatePanel("Panel", $("#LeftSideHeroes"), "");
    preview.AddClass("HeroPreview");

    $("#LeftSideHeroes").MoveChildAfter(preview, $("#HeroAbilities"));

    preview.style.visibility = "collapse";
    preview.SetHasClass("NotAvailableHero", allHeroes[hero].disabled);
    
    var loading = $.CreatePanel("Panel", preview, "");
    loading.AddClass("LoadingImage");
    loading.AddClass("HeroPreviewLoading");

    var queueElement = {
        container: preview,
        children: value,
        loadingImage: loading
    };

    if (insertFirst) {
        previewLoadingQueue.unshift(queueElement);
    } else {
        previewLoadingQueue.push(queueElement);
    }

    return preview;
}

function PreloadHeroPreview(hero) {
    heroPreviews[hero] = PreloadPreview(hero, "<DOTAScenePanel antialias='true' class='HeroPreviewScene' unit='" + hero + "'/>");
}

function PreloadHeroPreviews(heroes) {
    for (var hero of heroes) {
        if (!heroAwards[hero]) {
            PreloadHeroPreview(hero);
        }
    }
}

function PreloadAwardPreview(hero, season) {
    HidePreview(hero);

    heroAwards[hero] = PreloadPreview(hero, "<DOTAScenePanel antialias='true' class='HeroPreviewScene' light='light' camera='default' map='maps/rewards/" + season + "'/>", true);
    heroPreviews[hero] = heroAwards[hero];
}

function SetAbilityButtonTooltipEvents(button, name) {
    button.SetPanelEvent("onmouseover", function() {
        $.DispatchEvent("DOTAShowTextTooltip", button, $.Localize("AbilityTooltip_" + name));
    });

    button.SetPanelEvent("onmouseout", function() {
        $.DispatchEvent("DOTAHideTextTooltip");
    });
}

function ShowHeroAbilities(heroName) {
    var hero = allHeroes[heroName];
    var customIcons = {};

    if (hero.customIcons) {
        for (var ability in hero.customIcons) {
            customIcons[ability] = hero.customIcons[ability];
        }
    }

    if (!!heroAwards[heroName]) {
        $("#RankAwardText").SetDialogVariableInt("season", parseInt(_.invert(seasonAwards)[heroName]) + 1);
    }
    
    $("#AchievementRow").SetHasClass("Hidden", !heroAwards[heroName])

    var abilitiesToShow = [["A"], ["Q", 0], ["W", 1], ["E", 2], ["R", 5]];

    for (var pair of abilitiesToShow) {
        var ability = pair[0];

        var found =
            _(hero.abilities)
                .chain()
                .filter(function(a) {
                    return EndsWith(a, ability.toLowerCase());
                })
                .first()
                .value();

        found = (CustomNetTables.GetTableValue("static", "abilities") || {})[found];

        var row = $("#AbilityRow" + ability);

        if (row && found) {
            var image = row.Children()[0];
            var label = row.Children()[1];
            var shortcut = image.Children()[0];

            var icon = GetTexture(found, hero.customIcons);
            image.SetImage(icon);

            SetAbilityButtonTooltipEvents(image, found.name);

            if (ability === "A") {
                label.text = "HeroRange_" + hero.range;
            } else {
                label.text = hero.name.substring("npc_dota_hero_".length) + "_Desc" + ability;

                shortcut.text = Game.GetKeybindForAbility(pair[1] || 0);
            }
        }
    }
}

function ShowHeroCosmetics(heroName) {
    var parent = $("#HeroCosmetics");
    parent.RemoveAndDeleteChildren();

    var all = CustomNetTables.GetTableValue("pass", "heroes") || {};
    var assets = all.cosmetics[heroName.substring("npc_dota_hero_".length)];

    if (!assets) {
        return;
    }

    var experience = (CustomNetTables.GetTableValue("pass", "experience") || {})[Game.GetLocalPlayerID()];

    if (!experience) {
        return;
    }

    var level = experience / 1000;
    var toShow = [];

    for (var id in assets) {
        var asset = assets[id];

        if (asset.level && level >= asset.level) {
            toShow.push(asset);
        }

        if (asset.type == "pass_base") {
            toShow.push(asset);
        }
    }

    for (var asset of toShow) {
        var row = $.CreatePanel("Panel", parent, undefined);
        var image = $.CreatePanel("Image", row, undefined);
        var text = $.CreatePanel("Label", row, undefined);
        image.SetScaling("stretch-to-fit-y-preserve-aspect");

        if (asset.emote) {
            image.AddClass("RewardEmote");
            text.text = $.Localize("#EmoteReward");
        }

        if (asset.taunt) {
            image.AddClass("RewardTaunt");
            text.text = $.Localize("#TauntReward");
        }

        if (asset.item) {
            var img = all.images[asset.item.toString()].split(",")[0];
            image.SetImage("file://{images}/" + img + ".png");
            text.text = $.Localize("#ItemReward");
        }

        row.AddClass("CosmeticsRow");
    }
}

function ShowHeroDetails(heroName) {
    var selected = selectedHeroes[Game.GetLocalPlayerID()];

    if (selected && selected != "null" && selected != heroName) {
        return;
    }

    var abilityPanel = $("#HeroAbilities");
    var heroData = allHeroes[heroName];
    var notAvailable = allHeroes[heroName].disabled;

    ShowHeroAbilities(heroName);
    ShowHeroCosmetics(heroName);
    $("#HeroCosmetics").visible = !notAvailable;
    $("#HeroAbilities").visible = !notAvailable;
    $("#HeroName").text = $.Localize("#HeroName_" + heroData.name).toUpperCase();

    $("#HeroAbilities").SetHasClass("NotAvailableHero", notAvailable);
    $("#HeroName").SetHasClass("NotAvailableHero", notAvailable);

    heroPreviews[heroName].style.visibility = "visible";
    heroPreviews[heroName].AddClass("HeroPreviewIn");

    if (previewSchedule != 0) {
        $.CancelScheduled(previewSchedule);

        if (hiddingCurrentPreview != heroName) {
            heroPreviews[hiddingCurrentPreview].style.visibility = "collapse";
        }

        previewSchedule = 0;
    }
}

function HideHeroDetails(heroName) {
    var selected = selectedHeroes[Game.GetLocalPlayerID()];

    if (!selected || selected == "null") {
        heroPreviews[heroName].RemoveClass("HeroPreviewIn");
        hiddingCurrentPreview = heroName;

        previewSchedule = $.Schedule(0.1, function() {
            $("#HeroAbilities").visible = false;
            $("#HeroCosmetics").visible = false;
            $("#HeroName").text = "";

            heroPreviews[heroName].style.visibility = "collapse";
            previewSchedule = 0;
        });
    } else {
        ShowHeroDetails(selected);
    }
}

function HidePreview(hero) {
    if (heroPreviews[hero]) {
        heroPreviews[hero].RemoveClass("HeroPreviewIn");
        heroPreviews[hero].style.visibility = "collapse";
    }
}

function HideAll() {
    $("#HeroAbilities").visible = false;
    $("#HeroCosmetics").visible = false;
    $("#HeroName").text = "";

    for (var hero in heroPreviews) {
        HidePreview(hero);
    }
}

function PickRandomHero(){
    if (selectedHeroes[Game.GetLocalPlayerID()] == "null") {
        GameEvents.SendCustomGameEventToServer("selection_random", {});
    }
}

function AddButtonEvents(button, name, questComplete) {
    button.onactivate = function(panel) {
        var lock = $("#DifficultyLock");

        if (panel.GetParent().GetParent() == $("#HardHeroes") && lock) {
            return;
        }

        GameEvents.SendCustomGameEventToServer("selection_hero_click", { "hero": name });
    };

    button.onmouseover = function(panel) {
        GameEvents.SendCustomGameEventToServer("selection_hero_hover", { "hero": name });

        if (questComplete == false) {
             $.DispatchEvent("DOTAShowTextTooltip", panel, $.Localize("QuestAvailable"))
        }

        ShowHeroDetails(name);
    };

    button.onmouseout = function(){
        GameEvents.SendCustomGameEventToServer("selection_hero_hover", { "hero": "null" });

        if (questComplete == false) {
            $.DispatchEvent("DOTAHideTextTooltip");
        }

        HideHeroDetails(name);
    };
}

function AddDisabledButtonEvents(button, name) {
    button.onmouseover = function(panel) {
        $.DispatchEvent("DOTAShowTextTooltip", panel, $.Localize("AvailableSoon"))

        ShowHeroDetails(name);
    };

    button.onmouseout = function(){
        $.DispatchEvent("DOTAHideTextTooltip");

        HideHeroDetails(name);
    };
}

function AddBannedButtonEvents(button, name) {
    button.onmouseover = function(panel) {
        $.DispatchEvent("DOTAShowTextTooltip", panel, $.Localize("#HeroBanned"))

        ShowHeroDetails(name);
    };

    button.onmouseout = function(){
        $.DispatchEvent("DOTAHideTextTooltip");

        HideHeroDetails(name);
    };
}

function FindQuestHeroes(quests) {
    var result = {};

    $.Each(quests, function(q) {
        var transform = function(s) {
            return "npc_dota_hero_" + s.toLowerCase();
        };

        var complete = q.progress >= q.goal;

        if (q.hero) {
            result[transform(q.hero)] = complete;
        }

        if (q.secondaryHero) {
            result[transform(q.secondaryHero)] = complete;
        }
    })

    return result;
}

function CreateHeroList(heroList, heroes, quests, selectedHeroes, achievements, newPlayer, rows, randomButtonRow){
    var structure = [];

    if (!heroes) {
        return;
    }

    heroes = _(heroes).sortBy(function(hero) { return allHeroes[hero].disabled });

    var heroesInRow = rows[0];
    var randomAdded = false;
    var questHeroes = !!quests ? FindQuestHeroes(quests[Game.GetLocalPlayerID()] || []) : {};
    var localInfo = Game.GetPlayerInfo(Game.GetLocalPlayerID()) || {};
    var localTeam = localInfo.player_team_id || -1;
    var spectator = localTeam == -1;
    var eliteHeroes = [];

    if (achievements) {
        var achievement = achievements[Game.GetLocalPlayerID()];

        if (achievement) {
            if (achievement.achievedSeasons) {
                for (var season of _.values(achievement.achievedSeasons)) {
                    eliteHeroes.push(seasonAwards[season]);
                }
            }
        }
    }

    for (var i = 0, currentRow = 0; i < heroes.length; currentRow++, i += heroesInRow, heroesInRow = rows[currentRow]) {
        var row = {
            class: "HeroButtonRow",
            children: []
        };

        for (var j = i; j < heroes.length && j < i + heroesInRow; j++) {
            var hero = heroes[j];
            var notAvailable = !!allHeroes[hero].disabled;
            var banned = !!allHeroes[hero].banned;
            var hide = (!allHeroes[hero].forNewPlayers && questHeroes[hero] == undefined) && newPlayer;
            /*var t = _.filter(_.values(allHeroes[hero].abilities), function(n) { return EndsWith(n, "_a") });

            if (t.length != 0 || notAvailable) {
                continue;
            }*/

            var button = {
                class: [
                    "HeroButtonContainer",
                    newPlayer ? "NewPlayer" : null,
                    eliteHeroes.indexOf(hero) !== -1 ? "HeroButtonElite" : null,
                    hide ? "Hidden" : null
                ]
            };

            if (currentRow == randomButtonRow - 1 && (j - i) == Math.floor(heroesInRow / 2) && !randomAdded) {
                j--;
                randomAdded = true;

                button.children = {
                    class: "RandomButton"
                };

                button.onactivate = PickRandomHero;
            } else {
                var selected = false;

                for (var id in (selectedHeroes || {}).selected) {
                    var selectedTeam = Game.GetPlayerInfo(parseInt(id)).player_team_id;
                    var sHero = selectedHeroes.selected[id];

                    if (!selectedHeroes.allowSame || (selectedHeroes.locked || selectedTeam == localTeam || spectator)) {
                        if (sHero == hero) {
                            selected = true;
                            button.style = { boxShadow: (playerColors[id] || "#ff0000") + " -2px -2px 4px 4px" };

                            break;
                        }
                    }
                }

                var mainChild = {
                    tag: "DOTAHeroImage",
                    class: [
                        "HeroButton",
                        (notAvailable || banned) ? "NotAvailableHeroButton" : null,
                        selected ? null : "HeroButtonDesaturated"
                    ],
                    heroimagestyle: "portrait",
                    heroname: heroes[j],
                    scaling: "stretch-to-fit-x-preserve-aspect",
                };

                button.children = [ mainChild ];

                if (notAvailable) {
                    AddDisabledButtonEvents(mainChild, hero);
                } else if (banned) {
                    AddBannedButtonEvents(mainChild, hero);
                } else {
                    var questComplete = questHeroes[hero];

                    if (questComplete != undefined) {
                        button.children.push({
                            class: [ "HeroButtonQuest", questComplete ? "HeroButtonQuestComplete" : "HeroButtonQuestInProgress" ]
                        });
                    }

                    AddButtonEvents(mainChild, hero, questComplete);
                }
            }

            row.children.push(button);
        }

        structure.push(row);
    }

    Structure.Create(heroList, structure);
}

function SelectionHoverClient(args){
    var hero = args.hero;
    var selectionImage = $("#SelectionImage" + args["player"]);

    selectionImage.heroname = hero;
    selectionImage.SetHasClass("AnimationImageHover", hero != "null")
}

function OnTimerTick(args){
    if (args["time"] != -1) {
        $("#TimerText").text = args["time"].toString();
    } else {
        $("#TimerText").text = $.Localize("#GameInfoTimesUp");
    }
}

function GameStateChanged(data){
    var bg = $("#HeroSelectionBackground");

    if (data.state == GAME_STATE_HERO_SELECTION){
        bg.style.visibility = "visible";
        SwitchClass(bg, "AnimationBackgroundInvisible", "AnimationBackgroundVisible")
        Game.EmitSound("UI.SelectionStart")

        $("#HeroAbilities").visible = false;
        $("#HeroCosmetics").visible = false;
        $("#HeroName").text = "";

        selectedHeroes = {};

        for (var preview in heroPreviews) {
            heroPreviews[preview].style.visibility = "collapse";
        }
    } else {
        SwitchClass(bg, "AnimationBackgroundVisible", "AnimationBackgroundInvisible")
    }
}

function FilterDifficulty(heroes, data, difficulty) {
    return _.filter(heroes, function(hero) {
        return data[hero].difficulty == difficulty;
    });
}

function ShowAllHeroes() {
    showAllHeroes = true;
    heroSelectionAggregator();
}

function UpdateHeroSelectionButtons(data){
    allHeroes = data.heroes;

    var heroes = Object.keys(allHeroes);

    heroes = _(heroes).sortBy(function(hero) { return allHeroes[hero].order });
    
    if (Object.keys(heroPreviews).length == 0) {
        previewLoadingQueue = [];

        PreloadHeroPreviews(heroes);
    }

    var easy = FilterDifficulty(heroes, allHeroes, "easy");
    var hard = FilterDifficulty(heroes, allHeroes, "hard");

    var players = (data.players || {}).players || {};
    var localPlayer = {};

    for (var key in players) {
        var player = players[key];

        if (player.id == Game.GetLocalPlayerID()) {
            localPlayer = player;
            break;
        }
    }

    var newPlayer = ((localPlayer.gamesPlayed || 6) <= 5) && !showAllHeroes;

    $("#HeroList").SetHasClass("NewPlayer", newPlayer);
    $("#ShowAllHeroesButton").SetHasClass("NewPlayer", newPlayer);

    CreateHeroList($("#EasyHeroes"), easy, data.quests, data.selectedHeroes, data.achievements, newPlayer, [ 5, 6, 6, 6, 7 ] , 4);
    CreateHeroList($("#HardHeroes"), hard, data.quests, data.selectedHeroes, data.achievements, newPlayer, [ 6, 5 ]);
}

function PlayersUpdated(data){
    $("#GameGoal").text = data.goal.toString();

    if (!!data.isDeathMatch) {
        $("#GameGoalText").text = $.Localize("#KillsToWin");
    }

    var playersPanel = $("#PlayersContent");
    DeleteChildrenWithClass(playersPanel, "TeamPanel");

    CreateScoreboardFromData(data.players, function(color, score, team) {
        var panel = $.CreatePanel("Panel", playersPanel, "");
        panel.AddClass("TeamPanel");

        var displayScore = Math.min(score, data.goal);

        var scoreContainer = $.CreatePanel("Panel", panel, "");
        scoreContainer.AddClass("TeamScoreContainer");

        if (!!data.isDeathMatch) {
            scoreContainer.AddClass("Hidden");
        }

        var scorePanel = $.CreatePanel("Label", scoreContainer, "");
        scorePanel.AddClass("TeamScore");

        if (displayScore == data.goal) {
            scorePanel.AddClass("TeamScoreSurvive");

            scorePanel.text = $.Localize("#Survive");
        } else {
            scorePanel.text = displayScore.toString();
            scorePanel.AddClass("TeamScoreNormal");
        }

        var players = $.CreatePanel("Panel", panel, "");
        players.AddClass("TeamPanelPlayers");
        players.style.color = color;

        for (var player of team) {
            var playerPanel = $.CreatePanel("Panel", players, "");
            playerPanel.AddClass("TeamPlayer");

            var playerHero = $.CreatePanel("DOTAHeroImage", playerPanel, "SelectionImage" + player.id);
            playerHero.AddClass("SelectionImage");
            playerHero.heroimagestyle = "landscape";
            playerHero.heroname = "";

            var playerName = $.CreatePanel("Label", playerPanel, "");
            playerName.text = player.name;

            var connectionStatePanel = $.CreatePanel("Panel", playerName, "");
            connectionStatePanel.AddClass("ConnectionStatePanel");

            playerConnectionStates[player.id] = connectionStatePanel;

            playerColors[player.id] = color;
        }
    });
}

function HeroSelectionUpdated(data){
    var oldSelected = selectedHeroes || {};
    selectedHeroes = data.selected || {};
    
    var localHeroSelected = false;

    var localInfo = Game.GetPlayerInfo(Game.GetLocalPlayerID()) || {};
    var localTeam = localInfo.player_team_id || -1;
    var spectator = localTeam == -1;

    for (var key in selectedHeroes){
        var hero = selectedHeroes[key];
        var selectionImage = $("#SelectionImage" + key);
        var id = parseInt(key);

        if (hero == "null"){
            selectionImage.RemoveClass("AnimationSelectedHero");
        } else {
            if (id == Game.GetLocalPlayerID()) {
                HideAll();
                ShowHeroDetails(hero);

                if (!oldSelected[key] || oldSelected[key] == "null") {
                    Game.EmitSound("UI.SelectHeroLocal");
                }

                localHeroSelected = true;
            }

            var selectedTeam = Game.GetPlayerInfo(id).player_team_id;

            if (data.allowSame) {
                if (!data.locked && selectedTeam != localTeam && !spectator) {
                    continue;
                }
            }

            selectionImage.heroname = hero;
            selectionImage.RemoveClass("AnimationImageHover");
            selectionImage.AddClass("AnimationSelectedHero");
        }
    }

    $("#HeroSelectionBackgroundScene").SetHasClass("HeroSelectionBackgroundSceneHeroSelected", localHeroSelected);
    $("#HeroSelectedRays").SetHasClass("Hidden", !localHeroSelected);
}

function AchievementsUpdated(achievements) {
    var achievement = achievements[Game.GetLocalPlayerID()];

    if (achievement) {
        if (achievement.achievedSeasons) {
            for (var season of _.values(achievement.achievedSeasons)) {
                PreloadAwardPreview(seasonAwards[season], season);
            }
        }
    }
}

function GameInfoChanged(gameInfo) {
    if (!gameInfo) {
        return;
    }
}

function CheckPause() {
    $.Schedule(0.3, CheckPause);
    $("#HeroSelectionBackground").SetHasClass("PauseBackground", Game.IsGamePaused());
    $("#PauseOverlay").style.visibility = Game.IsGamePaused() ? "visible" : "collapse";
}

function CheckPreviews() {
    $.Schedule(0.01, CheckPreviews);

    var somethingIsLoading = false;
    var notLoadedContainer = null;

    for (var data of previewLoadingQueue) {
        var container = data.container;
        var children = container.Children();
        var hasScene = false;

        for (var child of children) {
            if (child.paneltype == "DOTAScenePanel") {
                hasScene = true;

                if (!child.BHasClass("SceneLoaded")) {
                    somethingIsLoading = true;
                    break;
                }
            }
        }

        if (somethingIsLoading) {
            break;
        }

        if (!hasScene && !notLoadedContainer) {
            notLoadedContainer = data;
        }
    }

    if (!somethingIsLoading && !!notLoadedContainer) {
        notLoadedContainer.container.BCreateChildren(notLoadedContainer.children);
        notLoadedContainer.loadingImage.DeleteAsync(0);
    }
}

function CheckConnectionState() {
    $.Schedule(0.1, CheckConnectionState);

    for (var id in playerConnectionStates) {
        var panel = playerConnectionStates[id];
        var state = Game.GetPlayerInfo(parseInt(id)).player_connection_state;

        panel.SetHasClass("ConnectionStateDisconnected", state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_DISCONNECTED);
        panel.SetHasClass("ConnectionStateAbandoned", state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED);
        panel.GetParent().SetHasClass("ConnectionStateAbandonedName", state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_ABANDONED);
    }
}

DelayStateInit(GAME_STATE_HERO_SELECTION, function () {
    GameEvents.Subscribe("selection_hero_hover_client", SelectionHoverClient);
    GameEvents.Subscribe("timer_tick", OnTimerTick);

    heroSelectionAggregator = AggregateNetTables([
        { table: "static", key: "heroes" },
        { table: "main", key: "selectedHeroes" },
        { table: "pass", key: "quests"},
        { table: "ranks", key: "achievements" },
        { table: "main", key: "players" }
    ], UpdateHeroSelectionButtons)

    //SubscribeToNetTableKey("main", "heroes", true, HeroesUpdated);
    SubscribeToNetTableKey("main", "players", true, PlayersUpdated);
    SubscribeToNetTableKey("main", "gameState", true, GameStateChanged);
    SubscribeToNetTableKey("main", "gameInfo", true, GameInfoChanged);
    SubscribeToNetTableKey("main", "selectedHeroes", true, HeroSelectionUpdated);

    SubscribeToNetTableKey("ranks", "achievements", true, AchievementsUpdated);

    SubscribeToNetTableKey("pass", "experience", true, Pass.ExperienceUpdated);
    SubscribeToNetTableKey("pass", "quests", true, Pass.QuestsUpdated);

    $("#HeroSelectionChat").BLoadLayout("file://{resources}/layout/custom_game/simple_chat.xml", false, false);
    $("#HeroSelectionChat").RegisterListener("HeroSelectionEnter");

    CheckConnectionState();
    CheckPause();
    CheckPreviews();

    var hasTicket = Players.HasCustomGameTicketForPlayerID(Game.GetLocalPlayerID());
    $("#PassNotOwned").SetHasClass("Hidden", hasTicket);
    $("#PassContent").SetHasClass("Hidden", !hasTicket);
});