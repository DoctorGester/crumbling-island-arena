"use strict";

var dummy = "npc_dota_hero_wisp";

var availableHeroes = {};
var currentHero = null;
var abilityBar = null;
var buffBar = null;
var healthBar = null;

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

    GameUI.SetRenderBottomInsetOverride(0);
    GameUI.SetRenderTopInsetOverride(0);
}

function GetLocalHero(){
    return Players.GetLocalPlayerPortraitUnit();
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
    abilityBar.RegisterEvents();

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
    AddDebugButton("Add Test Hero", null).SetPanelEvent("onactivate", function(){
        GameEvents.SendCustomGameEventToServer("debug_create_test_hero", {
            name: "npc_dota_hero_" + $("#DebugHeroName").text.trim()
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
        $("#Scoreboard").RemoveClass("AnimationScoreboardHidden");

        Game.EmitSound("UI.RoundStart")
    } else {
        $("#HeroPanel").AddClass("AnimationHeroHudHidden");
        $("#HeroDetails").AddClass("AnimationHeroDetailsHidden");
        $("#Scoreboard").AddClass("AnimationScoreboardHidden");
    }
}

function HeroesUpdate(data){
    availableHeroes = data;
}

SetupUI();

(function () {
    SubscribeToNetTableKey("main", "debug", true, DebugUpdate)
    SubscribeToNetTableKey("main", "heroes", true, HeroesUpdate);
    SubscribeToNetTableKey("main", "gameState", true, GameStateChanged);

    UpdateUI();

    GameEvents.Subscribe("cooldown_error", function(data) {
        var eventData = { reason: 15, message: "dota_hud_error_ability_in_cooldown" };
        GameEvents.SendEventClientSide("dota_hud_error_message", eventData);
    });
})();