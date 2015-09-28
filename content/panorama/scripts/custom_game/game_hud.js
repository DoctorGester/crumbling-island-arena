"use strict";

var availableHeroes = {};
var abilityButtons = [];

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

function ShowTooltip(element, name){
	$.DispatchEvent("DOTAShowAbilityTooltip", element, name); 
}

function HideTooltip(){
	$.DispatchEvent("DOTAHideAbilityTooltip"); 
}

function FilterAbility(id){
	return !Abilities.IsAttributeBonus(id) && Abilities.IsActivated(id) && !Abilities.IsHidden(id);
}

function GetLocalHero(){
	return Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
}

function LoadHeroUI(){
	var heroId = GetLocalHero();

	LoadAbilities(heroId);
	LoadHealth(heroId);
}

function AnimateHealthBar(bar, show){
	bar.SetHasClass("HealthBarDead", !show);
}

function LoadHealth(heroId){
	var panel = $("#HealthPanel");
	panel.RemoveAndDeleteChildren();

	var health = Entities.GetMaxHealth(heroId);

	for (var i = 0; i < health; i++){
		var bar = $.CreatePanel("Panel", panel, "HealthBar" + i);
		bar.AddClass("HealthBar");

		if (i > Entities.GetHealth(heroId) - 1)
			AnimateHealthBar(bar, false);
	}
}

function DamageTakenEvent(args){
	var barNumber = Math.round(Entities.GetHealth(GetLocalHero()));

	AnimateHealthBar($("#HealthBar" + barNumber), false);
}

function HealEvent(args){
	var barNumber = Math.round(Entities.GetHealth(GetLocalHero())) - 1;

	AnimateHealthBar($("#HealthBar" + barNumber), true);
}

function FallEvent(args){
	var panel = $("#HealthPanel");
	var bars = panel.FindChildrenWithClassTraverse("HealthBar");

	for (var i = 0; i < bars.length; i++) {
		AnimateHealthBar(bars[i], false);
	}
}

function AbilityButton(parent, hero, ability) {
	this.parent = parent;
	this.image = $.CreatePanel("Image", parent, "");
	this.image.AddClass("AbilityButton");
	this.ability = ability;

	var executeCapture = (function(ability, hero) { 
		return function() {
			Abilities.ExecuteAbility(ability, hero, false);
		}
	} (this.ability, hero));

	var mouseOverCapture = (function(element, name) { 
		return function() {
			ShowTooltip(element, name);
		}
	} (this.image, Abilities.GetAbilityName(ability)));

	var mouseOutCapture = function() { 
		HideTooltip();
	};

	this.image.SetPanelEvent("onactivate", executeCapture);
	this.image.SetPanelEvent("onmouseover", mouseOverCapture);
	this.image.SetPanelEvent("onmouseout", mouseOutCapture);

	this.inside = $.CreatePanel("Panel", this.image, "");
	this.inside.AddClass("AbilityButtonInside");

	this.shortcut = $.CreatePanel("Label", this.image, "");
	this.shortcut.AddClass("ShortcutText")
	this.shortcut.text = Abilities.GetKeybind(this.ability);
	
	this.cooldown = $.CreatePanel("Label", this.image, "");
	this.cooldown.AddClass("CooldownText");

	var icon = "file://{images}/spellicons/" + Abilities.GetAbilityTextureName(ability) + ".png";
	var heroData = availableHeroes[Entities.GetUnitName(hero)]
	var abilityName = Abilities.GetAbilityName(ability)

	if (heroData && heroData.customIcons && heroData.customIcons[abilityName]){
		icon = "file://{images}/custom_game/" + heroData.customIcons[abilityName];
	}

	this.image.SetImage(icon);

	this.UpdateCD = function() {
		var color = "yellow";
		var saturation = "1";
		var remaining = Abilities.GetCooldownTimeRemaining(this.ability);
		var cd = Abilities.GetCooldownLength(this.ability);

		if (cd == 0 || Abilities.IsCooldownReady(this.ability)){
			cd = Abilities.GetCooldown(this.ability);
		}

		if (!Abilities.IsCooldownReady(this.ability)){
			color = "red";
			saturation = "0.25";
		}

		if (!Abilities.IsDisplayedAbility(this.ability)){
			color = "red";
			saturation = "0.0";
		}

		this.image.style.boxShadow = "0px 0px 5px 0px " + color;
		this.image.style.saturation = saturation;

		var progress = Math.round(remaining / cd * 100.0).toString();
		var text = cd.toFixed(1);

		if (!Abilities.IsCooldownReady(ability)){
			text = remaining.toFixed(1);
		}

		if (cd == 0) {
			progress = 0;
			text = "";
		}

		this.inside.style.height = progress + "%";
		this.cooldown.text = text;
	};

	this.GetName = function() {
		return Abilities.GetAbilityName(this.ability);
	};

	this.SetAsUltimate = function() {
		if (Abilities.GetLevel(this.ability) == 0) {
			this.image.AddClass("AnimationUltimateHidden");
		}
	};

	this.Enable = function () {
		this.image.RemoveClass("AnimationUltimateHidden");
	};
}

function FindUltimateButton(heroId) {
	var heroName = Entities.GetUnitName(heroId);

	for (var button of abilityButtons) {
		if (!availableHeroes || !availableHeroes[heroName]) {
			continue;
		}

		$.Msg("ulti " + availableHeroes[heroName].ultimate + " " + button.GetName());
		if (availableHeroes[heroName].ultimate == button.GetName()) {
			return button;
		}
	}
}

function LoadAbilities(heroId){
	var heroName = Entities.GetUnitName(heroId);
	var abilityPanel = $("#AbilityPanel");
	abilityPanel.RemoveAndDeleteChildren();
	abilityButtons = [];

	var count = Entities.GetAbilityCount(heroId);

	for (var i = 0; i < count; i++) {
		var ability = Entities.GetAbility(heroId, i);

		if (FilterAbility(ability)){
			var button = new AbilityButton(abilityPanel, heroId, ability);
			abilityButtons.push(button);
		}
	}

	var ult = FindUltimateButton(heroId);
	if (ult) ult.SetAsUltimate();
}

function UltimatesEnabledEvent(args){
	var heroId = GetLocalHero();
	FindUltimateButton(heroId).Enable();
}

function UpdateCooldowns(){
	$.Schedule(0.025, UpdateCooldowns);

	for (var button of abilityButtons) {
		button.UpdateCD();
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

	AddDebugButton("Show hero select", function(){
		GameEvents.SendCustomGameEventToServer("debug_show_selection", {});
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
	$.Msg(data);

	availableHeroes = data;
}

SetupUI();

(function () {
	GameEvents.Subscribe("update_heroes", LoadHeroUI);
	GameEvents.Subscribe("ultimates_enabled", UltimatesEnabledEvent);
	GameEvents.Subscribe("hero_takes_damage", DamageTakenEvent);
	GameEvents.Subscribe("hero_healed", HealEvent);
	GameEvents.Subscribe("hero_falls", FallEvent);

	SubscribeToNetTableKey("main", "debug", true, DebugUpdate)
	SubscribeToNetTableKey("main", "heroes", true, HeroesUpdate);
	SubscribeToNetTableKey("main", "timers", true, GameTimersUpdate);
	SubscribeToNetTableKey("main", "gameInfo", true, GameInfoChanged);

	UpdateCooldowns();

	//GameEvents.Subscribe("dota_player_update_selected_unit", LoadHeroUI);
})();