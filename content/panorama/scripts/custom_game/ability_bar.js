function ShowTooltip(element, name){
	$.DispatchEvent("DOTAShowAbilityTooltip", element, name); 
}

function HideTooltip(){
	$.DispatchEvent("DOTAHideAbilityTooltip"); 
}

function Ability(abilityId, button) {
	this.button = button;
	this.abilityId = abilityId;

	this.GetName = function() {
		return Abilities.GetAbilityName(this.abilityId);
	}

	this.GetDefaultTexture = function() {
		return Abilities.GetAbilityTextureName(this.abilityId)
	}
}

function AbilityBar(elementId, heroId) {
	this.element = $.(elementId);
	this.heroId = heroId;
	this.abilities = {};
	this.customIcons = {};

	this.UpdateCooldowns = function() {
		for (var key in this.abilities) {
			var ability = this.abilities[key];
			var id = ability.abilityId;
			var cd = Abilities.GetCooldownLength(id);
			var ready = Abilities.IsCooldownReady(id);
			var remaining = Abilities.GetCooldownTimeRemaining(id);

			if (cd == 0 || ready){
				cd = Abilities.GetCooldown(this.ability);
			}

			ability.button.SetCooldown(remaining, cd, ready);
		}
	}

	this.AddCustomIcon = function(abilityName, iconPath) {
		customIcons[abilityName] = iconPath;
	}

	this.DisableUltimate = function(abilityName) {
		this.ultimate = abilityName;
	}

	this.GetAbility = function(slot) {
		if (!this.buttons[slot]) {
			var abilities = new AbilityButton(this.element);
			var ability = new Ability(0, button);
			
			this.abilities[slot] = button;
			this.UpdateAbility(slot);
		}

		return this.abilities[slot];
	}

	this.UpdateAbility = function(slot) {
		var ability = GetAbility(slot);
		var oldId = ability.abilityId;

		ability.abilityId = Entities.GetAbility(this.heroId, slot);

		if (oldId != ability.abilityId) {
			// Setting icon
			var icon = "file://{images}/spellicons/" + ability.GetDefaultTexture() + ".png";
			var name = ability.GetName();

			if (this.customIcons[name]){
				icon = "file://{images}/custom_game/" + this.customIcons[name];
			}

			ability.button.SetIcon(icon);

			// Registering events
			var executeCapture = (function(ability, hero) { 
				return function() {
					Abilities.ExecuteAbility(ability, hero, false);
				}
			} (ability.abilityId, this.heroId));

			var mouseOverCapture = (function(element, name) { 
				return function() {
					ShowTooltip(element, name);
				}
			} (ability.button.image, name));

			var mouseOutCapture = function() { 
				HideTooltip();
			};

			ability.button.image.SetPanelEvent("onactivate", executeCapture);
			ability.button.image.SetPanelEvent("onmouseover", mouseOverCapture);
			ability.button.image.SetPanelEvent("onmouseout", mouseOutCapture);
		}
	}
}

function AbilityButton(parent, hero, ability) {
	this.parent = parent;
	this.image = $.CreatePanel("Image", parent, undefined);
	this.image.AddClass("AbilityButton");
	this.ability = ability;

	this.inside = $.CreatePanel("Panel", this.image, undefined);
	this.inside.AddClass("AbilityButtonInside");

	this.shortcut = $.CreatePanel("Label", this.image, undefined);
	this.shortcut.AddClass("ShortcutText")
	this.shortcut.text = Abilities.GetKeybind(this.ability);
	
	this.cooldown = $.CreatePanel("Label", this.image, undefined);
	this.cooldown.AddClass("CooldownText");

	this.SetIcon = function(icon) {
		this.image.SetImage(icon);
	}

	this.SetCooldown = function(remaining, cd, ready) {
		var color = "yellow";
		var saturation = "1";

		if (!ready){
			color = "red";
			saturation = "0.25";
		}

		this.image.style.boxShadow = "0px 0px 5px 0px " + color;
		this.image.style.saturation = saturation;

		var progress = Math.round(remaining / cd * 100.0).toString();
		var text = cd.toFixed(1);

		if (!ready){
			text = remaining.toFixed(1);
		}

		if (cd == 0) {
			progress = 0;
			text = "";
		}

		this.inside.style.height = progress + "%";
		this.cooldown.text = text;
	}

	this.SetAsUltimate = function() {
		if (Abilities.GetLevel(this.ability) == 0) {
			this.image.AddClass("AnimationUltimateHidden");
		}
	}

	this.Enable = function () {
		this.image.RemoveClass("AnimationUltimateHidden");
	}
}
