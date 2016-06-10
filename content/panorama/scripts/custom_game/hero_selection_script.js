var allHeroes = {};
var heroButtons = {};
var playerColors = {};
var selectedHeroes = {};
var previewSchedule = 0;
var hidingCurrentPreview = null;
var playerConnectionStates = {};
var heroPreviews = {};

function CreateDifficultyLock() {
    // Dis gon be ugly
    var lockedHeroes = $("#HardHeroes");
    var background = $("#HeroSelectionBackground");
    var relation = 1080 / background.actuallayoutheight;

    var lock = $.CreatePanel("Panel", $("#HeroSelectionBackground"), "DifficultyLock");
    var startY = (lockedHeroes.GetPositionWithinWindow().y - 3) * relation;

    var widestRow = _(lockedHeroes.Children()).max(function(row) { return row.actuallayoutwidth });

    var startX = (widestRow.GetPositionWithinWindow().x - 3) * relation;

    if (startX == Infinity || startY == Infinity) {
        $.Schedule(0.01, CreateDifficultyLock);
        lock.DeleteAsync(0);
        return;
    }

    lock.style.x = startX + "px";
    lock.style.y = startY + "px";
    lock.style.height = ((lockedHeroes.actuallayoutheight + 6) * relation) + "px";
    lock.style.width = ((widestRow.actuallayoutwidth + 6) * relation) + "px";

    var image = $.CreatePanel("Panel", lock, "");
    var text = $.CreatePanel("Label", lock, "");
    
    text.text = $.Localize("LockedHeroes");
}

function PreloadHeroPreviews(heroes) {
    var previewStyle = "width: 100%; height: 100%; margin-top: -100px; opacity-mask: url(\"s2r://panorama/images/masks/softedge_box_png.vtex\");";
    for (var hero of heroes) {
        var preview = $.CreatePanel("Panel", $("#LeftSideHeroes"), "");
        preview.AddClass("HeroPreview");
        $("#LeftSideHeroes").MoveChildAfter(preview, $("#HeroAbilities"));

        preview.style.visibility = "collapse";
        preview.SetHasClass("NotAvailableHero", allHeroes[hero].disabled);
        preview.LoadLayoutFromStringAsync("<root><Panel><DOTAScenePanel style='" + previewStyle + "' unit='" + hero + "'/></Panel></root>", false, false);

        heroPreviews[hero] = preview;
    }
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
        for (ability in hero.customIcons) {
            customIcons[ability] = hero.customIcons[ability];
        }
    }

    var abilitiesToShow = ["Q", "W", "E", "R"];

    for (var ability of abilitiesToShow) {
        var found = 
            _(hero.abilities)
                .chain()
                .filter(function(a) {
                    return EndsWith(a.name, ability.toLowerCase());
                })
                .first()
                .value();

        var row = $("#AbilityRow" + ability);

        if (row && found) {
            var image = row.Children()[0];
            var label = row.Children()[1];

            var icon = GetTexture(found, hero.customIcons);
            image.SetImage(icon);

            SetAbilityButtonTooltipEvents(image, found.name);

            label.text = hero.name.substring("npc_dota_hero_".length) + "_Desc" + ability;
        }
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
    $("#HeroAbilities").visible = true;
    $("#HeroName").text = $.Localize("#HeroName_" + heroData.name);

    $("#HeroAbilities").SetHasClass("NotAvailableHero", notAvailable);
    $("#HeroName").SetHasClass("NotAvailableHero", notAvailable);

    heroPreviews[heroName].style.visibility = "visible";
    heroPreviews[heroName].AddClass("HeroPreviewIn");

    if (previewSchedule != 0) {
        $.CancelScheduled(previewSchedule);
        heroPreviews[hiddingCurrentPreview].style.visibility = "collapse";
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
            $("#HeroName").text = "";

            heroPreviews[heroName].style.visibility = "collapse";
            previewSchedule = 0;
        });
    } else {
        ShowHeroDetails(selected);
    }
}

function PickRandomHero(){
    if (selectedHeroes[Game.GetLocalPlayerID()] == "null") {
        GameEvents.SendCustomGameEventToServer("selection_random", {});
        Game.EmitSound("UI.SelectHeroLocal");
    }
}

function AddButtonEvents(button, name) {
    button.SetPanelEvent("onactivate", function() {
        var heroSelected = _.contains(_.values(selectedHeroes), name);
        var lock = $("#DifficultyLock");

        if (heroButtons[name].GetParent().GetParent() == $("#HardHeroes") && lock) {
            return;
        }

        if (selectedHeroes[Game.GetLocalPlayerID()] == "null" && !heroSelected) {
            GameEvents.SendCustomGameEventToServer("selection_hero_click", { "hero": name });
            Game.EmitSound("UI.SelectHeroLocal");
        }
    });

    button.SetPanelEvent("onmouseover", function() {
        GameEvents.SendCustomGameEventToServer("selection_hero_hover", { "hero": name });

        ShowHeroDetails(name);
    });

    button.SetPanelEvent("onmouseout", function(){
        GameEvents.SendCustomGameEventToServer("selection_hero_hover", { "hero": "null" });

        HideHeroDetails(name);
    });
}

function AddDisabledButtonEvents(button, name) {
    button.SetPanelEvent("onmouseover", function() {
        $.DispatchEvent("DOTAShowTextTooltip", button, $.Localize("Available_on_" + name))

        ShowHeroDetails(name);
    });

    button.SetPanelEvent("onmouseout", function(){
        $.DispatchEvent("DOTAHideTextTooltip");

        HideHeroDetails(name);
    });
}

function CreateHeroList(heroList, heroes, rows, randomButtonRow){
    DeleteChildrenWithClass(heroList, "HeroButtonContainer");

    heroes = _(heroes).sortBy(function(hero) { return allHeroes[hero].disabled });

    var heroesInRow = rows[0];
    var randomAdded = false;

    for (var i = 0, currentRow = 0; i < heroes.length; currentRow++, i += heroesInRow, heroesInRow = rows[currentRow]) {
        var row = $.CreatePanel("Panel", heroList, "");
        row.AddClass("HeroButtonRow");

        for (var j = i; j < heroes.length && j < i + heroesInRow; j++) {
            var notAvailable = allHeroes[heroes[j]].disabled;

            var container = $.CreatePanel("Panel", row, "");
            container.AddClass("HeroButtonContainer");

            if (currentRow == randomButtonRow - 1 && (j - i) == Math.floor(heroesInRow / 2) && !randomAdded) {
                j--;
                randomAdded = true;

                var button = $.CreatePanel("Panel", container, "");
                button.AddClass("RandomButton");

                container.SetPanelEvent("onactivate", PickRandomHero);
            } else {
                var button = $.CreatePanel("DOTAHeroImage", container, "");
                button.AddClass("HeroButton");
                button.SetHasClass("NotAvailableHeroButton", notAvailable);
                button.SetScaling("stretch-to-fit-x-preserve-aspect");
                button.heroname = heroes[j];
                button.heroimagestyle = "portrait";

                if (notAvailable) {
                    AddDisabledButtonEvents(container, heroes[j])
                } else {
                    AddButtonEvents(container, heroes[j]);
                }

                heroButtons[heroes[j]] = container;
            }
        }
    }
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
        $("#HeroName").text = "";

        for (var key in heroButtons) {
            heroButtons[key].style.boxShadow = null;
            heroButtons[key].RemoveClass("HeroButtonSaturated");
        }

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

function HeroesUpdated(data){
    if (!data) {
        return;
    }

    allHeroes = data;

    var heroes = Object.keys(data);

    heroes = _(heroes).sortBy(function(hero) { return data[hero].order });

    PreloadHeroPreviews(heroes);

    var easy = FilterDifficulty(heroes, data, "easy");
    var hard = FilterDifficulty(heroes, data, "hard");

    CreateHeroList($("#EasyHeroes"), easy, [ 5, 6, 4 ] , 3);
    CreateHeroList($("#HardHeroes"), hard, [ 4, 4 ]);
}

function PlayersUpdated(data){
    if (!data) {
        return;
    }

    $("#GameGoal").text = data.goal.toString();

    var playersPanel = $("#PlayersContent");
    DeleteChildrenWithClass(playersPanel, "TeamPanel");

    CreateScoreboardFromData(data.players, function(color, score, team) {
        var panel = $.CreatePanel("Panel", playersPanel, "");
        panel.AddClass("TeamPanel");

        var scorePanel = $.CreatePanel("Label", panel, "");
        scorePanel.AddClass("TeamScore");
        scorePanel.text = Math.min(score, data.goal).toString();

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
    selectedHeroes = data || {};

    for (var key in data){
        var hero = data[key];
        var selectionImage = $("#SelectionImage" + key);
        var id = parseInt(key);

        if (hero == "null"){
            selectionImage.RemoveClass("AnimationSelectedHero");
        } else {
            if (id == Game.GetLocalPlayerID()) {
                ShowHeroDetails(hero);
            }

            selectionImage.heroname = hero;
            selectionImage.RemoveClass("AnimationImageHover");
            selectionImage.AddClass("AnimationSelectedHero");

            heroButtons[hero].style.boxShadow = playerColors[id] + " -2px -2px 4px 4px";
            heroButtons[hero].AddClass("HeroButtonSaturated");
        }
    }
}

function GameInfoChanged(gameInfo) {
    if (!gameInfo) {
        return;
    }

    var lock = $("#DifficultyLock");
    if (gameInfo.hardHeroesLocked == 1) {
        if (!lock)
            CreateDifficultyLock();
    } else {
        if (lock) {
            lock.DeleteAsync(0);
        }
    }
}

function CheckPause() {
    $.Schedule(0.3, CheckPause);
    $("#HeroSelectionBackground").SetHasClass("PauseBackground", Game.IsGamePaused());
    $("#PauseOverlay").style.visibility = Game.IsGamePaused() ? "visible" : "collapse";
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

(function () {
    GameEvents.Subscribe("selection_hero_hover_client", SelectionHoverClient);
    GameEvents.Subscribe("timer_tick", OnTimerTick);

    SubscribeToNetTableKey("main", "heroes", true, HeroesUpdated);
    SubscribeToNetTableKey("main", "players", true, PlayersUpdated);
    SubscribeToNetTableKey("main", "gameState", true, GameStateChanged);
    SubscribeToNetTableKey("main", "gameInfo", true, GameInfoChanged);
    SubscribeToNetTableKey("main", "selectedHeroes", true, HeroSelectionUpdated);

    $("#HeroSelectionChat").BLoadLayout("file://{resources}/layout/custom_game/simple_chat.xml", false, false);
    $("#HeroSelectionChat").RegisterListener("HeroSelectionEnter");

    CheckConnectionState();
    CheckPause();
})();