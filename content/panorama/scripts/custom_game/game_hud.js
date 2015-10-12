"use strict";

var dummy = "npc_dota_hero_wisp";

var availableHeroes = {};
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
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_MENU_BUTTONS, false);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false);

	GameUI.SetRenderBottomInsetOverride(0);
}

function GetLocalHero(){
	return Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
}

function LoadHeroUI(){
	var heroId = GetLocalHero();

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

	if (Entities.GetUnitName(heroId) != dummy) {
		abilityBar.SetProvider(new EntityAbilityDataProvider(heroId));
		abilityBar.RegisterEvents();

		healthBar.SetEntity(heroId);
		buffBar.SetEntity(heroId);
	} else {
		abilityBar.SetProvider(new EmptyAbilityDataProvider());
		abilityBar.RegisterEvents();
	}
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

function UpdateCooldowns(){
	$.Schedule(0.025, UpdateCooldowns);

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

function TimerString(number){
	var floating = parseFloat(Math.max(number, 0) / 10).toFixed(1);
	return floating.toString();
}

function GameTimersUpdate(data){
	if (data == undefined){
		return;
	}

	$("#UltsTimer").text = TimerString(data.ults);
	$("#Stage2Timer").text = TimerString(data.stageTwo);
	$("#Stage3Timer").text = TimerString(data.stageThree);
	$("#SuddenDeathTimer").text = TimerString(data.suddenDeath);
}

function AddDebugButton(text, callback){
	var panel = $("#DebugPanel");
	var button = $.CreatePanel("Button", panel, "");
	button.AddClass("DebugButton");
	button.SetPanelEvent("onactivate", callback);

	var label = $.CreatePanel("Label", button, "");
	label.text = text;
	label.AddClass("DebugButtonText");
}

function FillDebugPanel(){
	AddDebugButton("Take 1 damage", function(){
		GameEvents.SendCustomGameEventToServer("debug_take_damage", {});
	});

	AddDebugButton("Heal 1 health", function(){
		GameEvents.SendCustomGameEventToServer("debug_heal_health", {});
	});

	AddDebugButton("Heal debug hero", function(){
		GameEvents.SendCustomGameEventToServer("debug_heal_debug_hero", {});
	});

	AddDebugButton("Check round end", function(){
		GameEvents.SendCustomGameEventToServer("debug_check_end", {});
	});

	AddDebugButton("Switch end check", function(){
		GameEvents.SendCustomGameEventToServer("debug_switch_end_check", {});
	});

	AddDebugButton("Reload hero UI", function () {
		LoadHeroUI();
	});
}

function DebugUpdate(data){
	if (!data){
		return;
	}

	if (data.enabled){
		FillDebugPanel();
	}
}

function GameInfoChanged(data){
	if (data.state == GAME_STATE_ROUND_IN_PROGRESS){
		$("#HeroPanel").RemoveClass("AnimationHeroHudHidden");
		$("#TimersPanel").RemoveClass("AnimationTimersHidden");

		LoadHeroUI();
	} else {
		$("#HeroPanel").AddClass("AnimationHeroHudHidden");
		$("#TimersPanel").AddClass("AnimationTimersHidden");
	}
}

function HeroesUpdate(data){
	availableHeroes = data;
}

SetupUI();

(function () {
	GameEvents.Subscribe("update_heroes", LoadHeroUI);

	SubscribeToNetTableKey("main", "debug", true, DebugUpdate)
	SubscribeToNetTableKey("main", "heroes", true, HeroesUpdate);
	SubscribeToNetTableKey("main", "timers", true, GameTimersUpdate);
	SubscribeToNetTableKey("main", "gameInfo", true, GameInfoChanged);

	UpdateCooldowns();

	//GameEvents.Subscribe("dota_player_update_selected_unit", LoadHeroUI);
})();