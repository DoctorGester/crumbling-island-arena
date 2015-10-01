var allHeroes = {};

function ShowHeroDetails(heroName) {
	var abilityPanel = $("#HeroAbilities");
	var heroData = allHeroes[heroName];

	$("#HeroName").text = $.Localize("#HeroName_" + heroData.name);

	DeleteChildrenWithClass(abilityPanel, "AbilityButton");

	for (var index in heroData.abilities) {
		var ability = heroData.abilities[index];

		if (ability.name.indexOf("sub") != -1) {
			continue;
		}

		var element = $.CreatePanel("Image", abilityPanel, "");
		var icon = "file://{images}/spellicons/" + ability.texture + ".png";

		if (heroData.customIcons && heroData.customIcons[ability.name]){
			icon = "file://{images}/custom_game/" + heroData.customIcons[ability.name];
		}

		element.AddClass("AbilityButton");
		element.SetImage(icon);
	}
}

function AddHoverHeroDetails(element, heroName){
	var mouseOver = (function(element, heroName) { 
		return function() {
			ShowHeroDetails(heroName);
		}
	} (element, heroName));
}

function CreatePlayerList(players){
	var playerList = $("#NameColumn");
	DeleteChildrenWithClass(playerList, "NamePanel");

	for (var i = 0; i < players.length; i++) {
		var player = players[i];

		var panel = $.CreatePanel("Panel", playerList, "");
		panel.AddClass("NamePanel");

		var mouseOver = (function(element, id) { 
			return function() {
				$.DispatchEvent("DOTAShowProfileCardTooltip", element, id, false); 
			}
		} (panel, player.steamId));

		var mouseOut = function(){
			$.DispatchEvent("DOTAHideProfileCardTooltip"); 
		}

		panel.SetPanelEvent("onmouseover", mouseOver);
		panel.SetPanelEvent("onmouseout", mouseOut);

		var name = $.CreatePanel("Label", panel, "");
		name.AddClass("NameLabel");
		name.text = player["name"];
		name.style.color = player["color"];
	}

	var selectionList = $("#SelectionColumn");
	DeleteChildrenWithClass(selectionList, "SelectionImage");

	for (var i = 0; i < players.length; i++) {
		var selection = $.CreatePanel("DOTAHeroImage", selectionList, "SelectionImage" + players[i].id);
		selection.AddClass("SelectionImage");
		selection.SetScaling("stretch-to-fit-y-preserve-aspect");
		selection.heroimagestyle = "landscape";
		selection.heroname = "";
	}
}

function CreateScoreColumn(players){
	var scoreColumn = $("#ScoreColumn");

	DeleteChildrenWithClass(scoreColumn, "ScorePanel");

	for (var i = 0; i < players.length; i++) {
		var player = players[i];

		var panel = $.CreatePanel("Panel", scoreColumn, "");
		panel.AddClass("ScorePanel");

		var label = $.CreatePanel("Label", panel, "");
		label.AddClass("ScoreText");
		label.text = player.score.toString();
	}
}

function CreateHeroList(heroes){
	var heroList = $("#HeroButtons");
	DeleteChildrenWithClass(heroList, "HeroButton");

	for (var i = 0; i < heroes.length; i++) {
		var button = $.CreatePanel("DOTAHeroImage", heroList, "");
		button.AddClass("HeroButton");
		button.SetScaling("stretch-to-fit-y-preserve-aspect");
		button.heroname = heroes[i];
		button.heroimagestyle = "landscape";

		var mouseOver = (function(element, name) { 
			return function() {
				GameEvents.SendCustomGameEventToServer("selection_hero_hover", { "hero": name });

				ShowHeroDetails(name);
			}
		} (button, heroes[i]));

		var mouseClick = (function(name) { 
			return function() {
				GameEvents.SendCustomGameEventToServer("selection_hero_click", { "hero": name });
			}
		} (heroes[i]));

		var mouseOut = function(){
			GameEvents.SendCustomGameEventToServer("selection_hero_hover", { "hero": "null" });
		}

		button.SetPanelEvent("onactivate", mouseClick);
		button.SetPanelEvent("onmouseover", mouseOver);
		button.SetPanelEvent("onmouseout", mouseOut);
	}
}

function SelectionHoverClient(args){
	var hero = args.hero;
	var selectionImage = $("#SelectionImage" + args["player"]);

	selectionImage.heroname = hero;
	selectionImage.SetHasClass("AnimationImageHover", hero != "null")
}

function OnTimerTick(args){
	$("#TimerText").text = args["time"].toString();
}

function GameInfoUpdated(data){
	var bg = $("#HeroSelectionBackground");

	if (data.state == GAME_STATE_HERO_SELECTION){
		bg.style.visibility = "visible";
		SwitchClass(bg, "AnimationBackgroundInvisible", "AnimationBackgroundVisible")
	} else {
		SwitchClass(bg, "AnimationBackgroundVisible", "AnimationBackgroundInvisible")
	}
}

function HeroesUpdated(data){
	var heroes = [];

	for (var key in data){
		heroes.push(key);
	}

	CreateHeroList(heroes);

	allHeroes = data;
}

function PlayersUpdated(data){
	var players = [];

	for (var key in data){
		var player = data[key];
		var result = {
			id: player.id,
			score: player.score,
			steamId: Game.GetPlayerInfo(player.id).player_steamid,
			name: Players.GetPlayerName(player.id),
			color: LuaColor(player.color)
		};

		players.push(result);
	}

	CreatePlayerList(players);
	CreateScoreColumn(players);
}

function HeroSelectionUpdated(data){
	for (var key in data){
		var hero = data[key];
		var selectionImage = $("#SelectionImage" + key);

		if (hero == "null"){
			selectionImage.RemoveClass("AnimationSelectedHero");
		} else {
			selectionImage.heroname = hero;
			selectionImage.RemoveClass("AnimationImageHover");
			selectionImage.AddClass("AnimationSelectedHero");
		}
	}
}

(function () {
	GameEvents.Subscribe("selection_hero_hover_client", SelectionHoverClient);
	GameEvents.Subscribe("timer_tick", OnTimerTick);

	SubscribeToNetTableKey("main", "heroes", true, HeroesUpdated);
	SubscribeToNetTableKey("main", "players", true, PlayersUpdated);
	SubscribeToNetTableKey("main", "gameInfo", true, GameInfoUpdated);
	SubscribeToNetTableKey("main", "selectedHeroes", true, HeroSelectionUpdated)

	//CustomNetTables.SubscribeNetTableListener("main", TableUpdated);

	//GameEvents.Subscribe("dota_player_update_selected_unit", Reload); // Testing
})();