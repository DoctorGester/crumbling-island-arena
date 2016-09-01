"use strict";

var dummy = "npc_dota_hero_wisp";

var availableHeroes = {};
var currentHero = null;
var abilityBar = null;
var buffBar = null;
var healthBar = null;
var chatLines = [];

GameUI.SetCameraPitchMin(60);
GameUI.SetCameraPitchMax(60);
GameUI.SetCameraLookAtPositionHeightOffset(100);
GameUI.GameChat = $("#GameChat");

function AddChatLine(hero, playerName, color, message, wasTopPlayer) {
    var line = $.CreatePanel("Panel", $("#GameChatContent"), "");
    var last = $("#GameChatContent").GetChild(0);
    line.AddClass("GameChatLine");
    line.AddClass("GameChatLineAppear");

    if (last != null) {
        $("#GameChatContent").MoveChildBefore(line, last);
    }

    var img = $.CreatePanel("DOTAHeroImage", line, "");

    img.AddClass("GameChatImage");
    img.heroimagestyle = "icon";
    img.heroname = hero;

    if (wasTopPlayer) {
        var trophy = $.CreatePanel("Panel", line, "");

        trophy.AddClass("TopPlayerIcon");
        trophy.AddClass("GameChatImage");
    }
    
    var label = $.CreatePanel("Label", line, "");
    label.SetDialogVariable("name", playerName);
    label.SetDialogVariable("color", color);
    label.SetDialogVariable("message", InsertEmotes(message, wasTopPlayer));
    label.html = true;
    label.text = $.Localize("#ChatLine", label);

    $("#GameChatContent").ScrollToBottom();

    $.Schedule(5, function(){
        line.AddClass("GameChatLineHidden");
    });
}

function OnKillMessage(args) {
    MessageQueue.QueueMessage(args.victim, args.token, args.sound);
}

function OnCustomChatSay(args) {
    var color = LuaColor(args.color);
    
    AddChatLine(args.hero, Players.GetPlayerName(args.player), color, args.message, args.wasTopPlayer);
}

function OnKillLogEntry(args) {
    var log = $("#KillLog");
    var last = log.GetChild(0);

    var entry = $.CreatePanel("Panel", log, "");
    entry.AddClass("KillLogEntry");
    entry.AddClass("KillLogEntryAppear");
    entry.style.backgroundColor = LuaColorA(args.color, 128);

    if (last != null) {
        log.MoveChildBefore(entry, last);
    }

    var img = $.CreatePanel("DOTAHeroImage", entry, "");
    img.heroimagestyle = "icon";
    img.heroname = args.killer;
    img.SetScaling("stretch-to-fit-y-preserve-aspect");

    img = $.CreatePanel("Image", entry, "");

    if (args.fell) {
        img.SetImage("file://{images}/custom_game/fall.png");
    } else {
        img.SetImage("file://{images}/custom_game/swords.png");
    }

    img.SetScaling("stretch-to-fit-y-preserve-aspect");

    img = $.CreatePanel("DOTAHeroImage", entry, "");
    img.heroimagestyle = "icon";
    img.heroname = args.victim;
    img.SetScaling("stretch-to-fit-y-preserve-aspect");
}

function SetupUI(){
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PANEL, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_ITEMS, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_QUICKBUY, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_COURIER, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_GOLD, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_TEAMS, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_GAME_NAME, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_CLOCK, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_MENU_BUTTONS, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME_CHAT, false);

    GameUI.SetRenderBottomInsetOverride(0);
    GameUI.SetRenderTopInsetOverride(0);
}

function GetLocalHero(){
    return Players.GetLocalPlayerPortraitUnit();
}

function GetLocalPlayedHero(){
    return _
        .chain(Entities.GetAllHeroEntities())
        .filter(function(entity) {
            return !Entities.IsUnselectable(entity) && Entities.IsControllableByPlayer(entity, Players.GetLocalPlayer());
        })
        .first()
        .value();
}

function LoadHeroUI(heroId){
    $("#HeroPortrait").heroname = Entities.GetUnitName(heroId);
    $("#HeroNameLabel").text = $.Localize("#HeroName_" + Entities.GetUnitName(heroId));

    if (abilityBar == null) {
        abilityBar = new AbilityBar("#AbilityPanel");
    }

    if (healthBar == null) {
        healthBar = new HealthBar("#HealthPanel", heroId);
    }

    if (buffBar == null) {
        buffBar = new BuffBar("#BuffPanel");
    }

    LoadCustomIcons();

    abilityBar.SetProvider(new EntityAbilityDataProvider(heroId));
    abilityBar.RegisterEvents(true);

    healthBar.SetEntity(heroId);
    buffBar.SetEntity(heroId);
}

function LoadCustomIcons(){
    for (var key in availableHeroes) {
        var hero = availableHeroes[key];

        if (hero.customIcons) {
            for (var iconKey in hero.customIcons) {
                abilityBar.AddCustomIcon(iconKey, hero.customIcons[iconKey]);
                buffBar.AddCustomIcon(iconKey, hero.customIcons[iconKey]);
            }
        }
    }
}

function UpdateUI(){
    $.Schedule(0.025, UpdateUI);

    var localHero = GetLocalHero();

    if (localHero != currentHero && Entities.GetUnitName(localHero) != dummy) {
        currentHero = localHero;
        LoadHeroUI(localHero);
    }

    if (healthBar != null) {
        healthBar.Update();
    }

    if (abilityBar != null) {
        abilityBar.Update();
    }

    if (buffBar != null) {
        buffBar.Update();
    }
}

function CenterCamera(on){
    GameUI.SetCameraTargetPosition(Entities.GetAbsOrigin(on || GetLocalHero()), 1.0);
}

function AddDebugButton(text, eventName){
    var panel = $("#DebugPanel");
    var button = $.CreatePanel("Button", panel, "");
    button.SetPanelEvent("onactivate", function(){
        GameEvents.SendCustomGameEventToServer(eventName, {});
    });

    $.CreatePanel("Label", button, "").text = text;

    return button;
}

function FillDebugPanel(){
    var heroText = $.CreatePanel("TextEntry", $("#DebugPanel"), "");
    heroText.multiline = false;
    heroText.textmode = "normal";
    heroText.text = "sven";

    AddDebugButton("Add Test Hero", null).SetPanelEvent("onactivate", function(){
        GameEvents.SendCustomGameEventToServer("debug_create_test_hero", {
            name: "npc_dota_hero_" + heroText.text.trim()
        });
    });

    AddDebugButton("Take 1 damage", "debug_take_damage");
    AddDebugButton("Heal 1 health", "debug_heal_health");
    AddDebugButton("Heal debug hero", "debug_heal_debug_hero");
    AddDebugButton("Check round end", "debug_check_end");
    AddDebugButton("Switch end check", "debug_switch_end_check");
    AddDebugButton("Switch debug display", "debug_switch_debug_display");
    AddDebugButton("Reset level", "debug_reset_level");
}

function DebugUpdate(data){
    if (!data){
        return;
    }

    if (data.enabled){
        FillDebugPanel();
    }
}

function GameStateChanged(data){
    var animations = {
        "HeroPanel": "AnimationHeroHudHidden",
        "DeathMatchContainer": "AnimationHeroHudHidden",
        "HeroDetails": "AnimationHeroDetailsHidden",
        "ScoreboardContainer": "AnimationScoreboardHidden",
        "KillLog": "AnimationKillLogHidden"
    };

    for (var panel in animations) {
        var animation = animations[panel];

        $("#" + panel).SetHasClass(animation, data.state != GAME_STATE_ROUND_IN_PROGRESS);
    }
    
    if (data.state == GAME_STATE_ROUND_IN_PROGRESS){
        $("#KillLog").RemoveAndDeleteChildren();
        $("#RoundMessageTop").AddClass("RoundMessageTopAnimation");
        $("#RoundMessageBottom").AddClass("RoundMessageBottomAnimation");

        $.Schedule(3, function() {
            $("#RoundMessageTop").RemoveClass("RoundMessageTopAnimation");
            $("#RoundMessageBottom").RemoveClass("RoundMessageBottomAnimation");
        });

        Game.EmitSound("UI.RoundStart");

        $.Schedule(0.2, function() {
            CenterCamera(GetLocalPlayedHero());
        });
    } else {
        $("#RoundMessageTop").RemoveClass("RoundMessageTopAnimation");
        $("#RoundMessageBottom").RemoveClass("RoundMessageBottomAnimation");
    }
}

function GameInfoChanged(data){
    if (data && data.roundNumber) {
        $("#RoundMessageBottom").text = (data.roundNumber - 1).toString();
    }
}

var DeathMatch = new (function() {
    this.ShowHeroAbilities = function(hero) {
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

                label.text = $.Localize(hero.name.substring("npc_dota_hero_".length) + "_Desc" + ability);
            }
        }
    }

    this.FilterDifficulty = function(difficulty) {
        return _.filter(Object.keys(this.heroes), function(hero) {
            return DeathMatch.heroes[hero].difficulty == difficulty;
        });
    }

    this.FillHeroList = function(parent, difficulty) {
        var heroes = this.FilterDifficulty(difficulty);

        heroes = _(heroes).sortBy(function(hero) {
            return DeathMatch.heroes[hero].order
        });

        heroes = _(heroes).sortBy(function(hero) {
            return DeathMatch.heroes[hero].difficulty
        });

        var currentRow = null;

        for (var index in heroes) {
            if (index % 4 == 0) {
                currentRow = $.CreatePanel("Panel", parent, "");
                currentRow.AddClass("DeathMatchHeroRow");
            }

            var hero = heroes[index];
            var heroData = this.heroes[hero];
            var heroButton = $.CreatePanel("DOTAHeroImage", currentRow, "");
            heroButton.SetScaling("stretch-to-fit-x-preserve-aspect");

            heroButton.heroimagestyle = "landscape";
            heroButton.heroname = hero;

            this.AddButtonEvents(heroButton, hero);
        }
    }

    this.HeroesUpdated = function(data) {
        this.heroes = data;
        this.FillHeroList($("#DeathMatchHeroesContentEasy"), "easy");
        this.FillHeroList($("#DeathMatchHeroesContentHard"), "hard");
    }

    this.ShowHeroDetails = function(hero){
        this.ShowHeroAbilities(this.heroes[hero]);

        $("#DeathMatchHeroMovie").heroname = hero;
        $("#DeathMatchHeroName").text = $.Localize("HeroName_" + hero).toUpperCase();
    }

    this.PlayersUpdated = function(data) {
        if (data.isDeathMatch) {
            var player = _(data.players).findWhere({ id: Game.GetLocalPlayerID() });
            $("#DeathMatchContainer").SetHasClass("Hidden", !player.isDead);
            $("#DeathMatchRespawnButtonIcon").heroname = player.hero;
            $("#DeathMatchHardHeroesLock").SetHasClass("Hidden", !data.deathMatchHeroesLocked);
        }
    }

    this.InstantRespawn = function() {
        this.Respawn("npc_dota_hero_" + $("#DeathMatchRespawnButtonIcon").heroname);
    }

    this.Respawn = function(hero) {
        GameEvents.SendCustomGameEventToServer("dm_respawn", { "hero": hero });
        this.HideHeroes();
    }

    this.Random = function() {
        GameEvents.SendCustomGameEventToServer("dm_random", {});
        this.HideHeroes();
    }

    this.AddButtonEvents = function(button, name) {
        button.SetPanelEvent("onactivate", function() {
            DeathMatch.Respawn(name);
        });

        button.SetPanelEvent("onmouseover", function() {
            DeathMatch.ShowHeroDetails(name);
        });
    }

    this.HideHeroes = function() {
        $("#DeathMatchHeroes").SetHasClass("Hidden", true);
    }

    this.OnRespawn = function(args) {
        GameUI.SetCameraTargetPosition([ args.x, args.y, 0 ], 1.0);
        Game.EmitSound("UI.Respawn");

        if (this.deathMusic) {
            Game.StopSound(this.deathMusic);
        }
    }

    this.OnDeath = function(args) {
        Game.EmitSound("UI.YouDied");
        this.deathMusic = Game.EmitSound("UI.YouDiedMusic");
    }

})();

function HeroesUpdate(data){
    availableHeroes = data;

    DeathMatch.HeroesUpdated(data);
}

SetupUI();

DelayStateInit(GAME_STATE_ROUND_IN_PROGRESS, function () {
    SubscribeToNetTableKey("main", "debug", true, DebugUpdate)
    SubscribeToNetTableKey("main", "heroes", true, HeroesUpdate);
    SubscribeToNetTableKey("main", "gameState", true, GameStateChanged);
    SubscribeToNetTableKey("main", "gameInfo", true, GameInfoChanged);
    SubscribeToNetTableKey("main", "players", true, DeathMatch.PlayersUpdated);

    UpdateUI();

    GameEvents.Subscribe("cooldown_error", function(data) {
        var eventData = { reason: 15, message: "dota_hud_error_ability_in_cooldown" };
        GameEvents.SendEventClientSide("dota_hud_error_message", eventData);
    });

    GameEvents.Subscribe("custom_chat_say", OnCustomChatSay);
    GameEvents.Subscribe("kill_log_entry", OnKillLogEntry);
    GameEvents.Subscribe("kill_message", OnKillMessage);
    GameEvents.Subscribe("dm_respawn_event", DeathMatch.OnRespawn);
    GameEvents.Subscribe("dm_death_event", DeathMatch.OnDeath);

    // We can't completely lose focus without deleting the element which has it
    AddEnterListener("GameHudChatEnter", function() {
        var state = CustomNetTables.GetTableValue("main", "gameState").state;

        if (state == GAME_STATE_ROUND_IN_PROGRESS || state == GAME_STATE_ROUND_ENDED) {
            $("#GameChatEntryContainer").BLoadLayout("file://{resources}/layout/custom_game/chat.xml", true, true);
            $("#GameChatEntry").SetFocus();
            $("#GameChat").RemoveClass("ChatHidden");
        }
    });
});