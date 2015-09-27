"use strict";

var availableHeroes = {};

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
	if (show){
		AnimatePanel(bar, { "background-color": "#3A9B00", "opacity": "1.0;" }, 0.5);
	} else {
		AnimatePanel(bar, { "background-color": "gray", "opacity": "0.4;" }, 0.5);
	}
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

function LoadAbilities(heroId){
	var abilityPanel = $("#AbilityPanel");
	abilityPanel.RemoveAndDeleteChildren();

	var count = Entities.GetAbilityCount(heroId);

	for (var i = 0; i < count; i++) {
		var ability = Entities.GetAbility(heroId, i);

		if (FilterAbility(ability)){
			var image = $.CreatePanel("Image", abilityPanel, "AbilityButton" + i);
			image.AddClass("AbilityButton");

			var executeCapture = (function(ability, hero) { 
				return function() {
					Abilities.ExecuteAbility(ability, hero, false);
				}
			} (ability, heroId));

			var mouseOverCapture = (function(element, name) { 
				return function() {
					ShowTooltip(element, name);
				}
			} (image, Abilities.GetAbilityName(ability)));

			var mouseOutCapture = function() { 
				HideTooltip();
			};

			image.SetPanelEvent("onactivate", executeCapture);
			image.SetPanelEvent("onmouseover", mouseOverCapture);
			image.SetPanelEvent("onmouseout", mouseOutCapture);

			var inside = $.CreatePanel("Panel", image, "");
			inside.AddClass("AbilityButtonInside");

			var shortcut = $.CreatePanel("Label", image, "");
			shortcut.AddClass("ShortcutText")
			shortcut.text = Abilities.GetKeybind(ability);
			
			var cooldown = $.CreatePanel("Label", image, "");
			cooldown.AddClass("CooldownText");

			var icon = "file://{images}/spellicons/" + Abilities.GetAbilityTextureName(ability) + ".png";
			var heroData = availableHeroes[Entities.GetUnitName(heroId)]
			var abilityName = Abilities.GetAbilityName(ability)

			$.Msg(heroData);

			if (heroData && heroData.customIcons && heroData.customIcons[abilityName]){
				icon = "file://{images}/custom_game/" + heroData.customIcons[abilityName];
			}

			image.SetImage(icon);

			if (Abilities.GetLevel(ability) == 0) {
				image.style.opacity = 0.0;
				AnimatePanel(image, { "transform": "scale3d(0.0, 0.0, 1.0)" }, 1.0);
			}
		}
	}
}

function UltimatesEnabledEvent(args){
	var heroId = GetLocalHero();
	var count = Entities.GetAbilityCount(heroId);

	for (var i = 0; i < count; i++) {
		var image = $("#AbilityButton" + i);

		if (image){
			image.style.opacity = 1.0;
			AnimatePanel(image, { "transform": "scale3d(1.0, 1.0, 1.0)" }, 0.5);
		}
	}
}

function UpdateCooldowns(){
	$.Schedule(0.025, UpdateCooldowns);

	var abilityPanel = $("#AbilityPanel");

	if (abilityPanel == null) {
		return;
	}

	var children = abilityPanel.Children();

	var heroId = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
	var count = Entities.GetAbilityCount(heroId);

	for (var i = 0; i < children.length; i++) {
		var button = children[i];
		var ability = Entities.GetAbility(heroId, i);

		if (button == null) {
			continue;
		}

		if (!FilterAbility(ability)){
			continue;
		}

		var text = button.FindChildrenWithClassTraverse("CooldownText")[0];

		if (text == null){
			continue;
		}

		var color = "yellow";
		var saturation = "1";
		var remaining = Abilities.GetCooldownTimeRemaining(ability);
		var cd = Abilities.GetCooldown(ability);

		if (cd == 0){
			continue;
		}

		if (!Abilities.IsCooldownReady(ability)){
			color = "red";
			saturation = "0.25";
		}

		var inside = button.FindChildrenWithClassTraverse("AbilityButtonInside")[0];

		button.style.boxShadow = "0px 0px 5px 0px " + color;
		button.style.saturation = saturation;

		var progress = Math.round(remaining / cd * 100.0).toString();
		inside.style.height = progress + "%";

		if (Abilities.IsCooldownReady(ability)){
			text.text = cd.toFixed(1);
		} else {
			text.text = remaining.toFixed(1);
		}
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
	})

	/*AddDebugButton("Reset map", function(){
		GameEvents.SendCustomGameEventToServer("debug_reset_map", {});
	});

	AddDebugButton("Stage 1 map", function(){

	});

	AddDebugButton("Stage 2 map", function(){

	});

	AddDebugButton("Stage 3 map", function(){

	});*/
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

	//GameEvents.Subscribe("dota_player_update_selected_unit", t);
})();