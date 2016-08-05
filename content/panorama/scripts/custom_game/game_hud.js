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

function AddChatLine(hero, playerName, color, message) {
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

    var label = $.CreatePanel("Label", line, "");
    label.SetDialogVariable("name", playerName);
    label.SetDialogVariable("color", color);
    label.SetDialogVariable("message", InsertEmotes(message));
    label.html = true;
    label.text = $.Localize("#ChatLine", label);

    $("#GameChatContent").ScrollToBottom();

    $.Schedule(5, function(){
        line.AddClass("GameChatLineHidden");
    });
}

function OnCustomChatSay(args) {
    var color = LuaColor(args.color);
    
    AddChatLine(args.hero, Players.GetPlayerName(args.player), color, args.message);
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
    if (data.state == GAME_STATE_ROUND_IN_PROGRESS){
        $("#HeroPanel").RemoveClass("AnimationHeroHudHidden");
        $("#HeroDetails").RemoveClass("AnimationHeroDetailsHidden");
        $("#ScoreboardContainer").RemoveClass("AnimationScoreboardHidden");
        $("#KillLog").RemoveClass("AnimationKillLogHidden");
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
        $("#HeroPanel").AddClass("AnimationHeroHudHidden");
        $("#HeroDetails").AddClass("AnimationHeroDetailsHidden");
        $("#ScoreboardContainer").AddClass("AnimationScoreboardHidden");
        $("#KillLog").AddClass("AnimationKillLogHidden");
        $("#RoundMessageTop").RemoveClass("RoundMessageTopAnimation");
        $("#RoundMessageBottom").RemoveClass("RoundMessageBottomAnimation");
    }
}


function GameInfoChanged(data){
    if (data && data.roundNumber) {
        $("#RoundMessageBottom").text = (data.roundNumber - 1).toString();
    }
}

function HeroesUpdate(data){
    availableHeroes = data;
}

SetupUI();

DelayStateInit(GAME_STATE_ROUND_IN_PROGRESS, function () {
    SubscribeToNetTableKey("main", "debug", true, DebugUpdate)
    SubscribeToNetTableKey("main", "heroes", true, HeroesUpdate);
    SubscribeToNetTableKey("main", "gameState", true, GameStateChanged);
    SubscribeToNetTableKey("main", "gameInfo", true, GameInfoChanged);

    UpdateUI();

    GameEvents.Subscribe("cooldown_error", function(data) {
        var eventData = { reason: 15, message: "dota_hud_error_ability_in_cooldown" };
        GameEvents.SendEventClientSide("dota_hud_error_message", eventData);
    });

    GameEvents.Subscribe("custom_chat_say", OnCustomChatSay);
    GameEvents.Subscribe("kill_log_entry", OnKillLogEntry);

    // We can't completely lose focus without deleting the element which has it
    AddEnterListener("GameHudChatEnter", function() {
        if ($("#HeroPanel").BCanSeeInParentScroll()) {
            $("#GameChatEntryContainer").BLoadLayout("file://{resources}/layout/custom_game/chat.xml", true, true);
            $("#GameChatEntry").SetFocus();
            $("#GameChat").RemoveClass("ChatHidden");
        }
    });
});