// AbilityDataProvider ->
//  GetAbilityData(slot)
//  GetAbilityCount()

function EmptyAbilityDataProvider() {
    this.GetAbilityData = function(slot) {
        return {};
    }

    this.GetAbilityCount = function() {
        return 0;
    }
}

function EntityAbilityDataProvider(entityId) {
    this.entityId = entityId;

    this.FilterAbility = function(id) {
        return !Abilities.IsAttributeBonus(id) && Abilities.IsDisplayedAbility(id);
    }

    this.FilterAbilities = function() {
        var abilities = [];
        var count = Entities.GetAbilityCount(this.entityId);

        for (var i = 0; i < count; i++) {
            var ability = Entities.GetAbility(this.entityId, i);

            if (this.FilterAbility(ability)) {
                abilities.push(ability);
            }
        }

        return abilities;
    }

    this.GetAbilityData = function(slot) {
        var ability = this.FilterAbilities()[slot];
        var data = {};

        data.id = ability;
        data.key = Abilities.GetKeybind(ability);
        data.name = Abilities.GetAbilityName(ability);
        data.texture = Abilities.GetAbilityTextureName(ability);
        data.cooldown = Abilities.GetCooldownLength(ability);
        data.ready = Abilities.IsCooldownReady(ability);
        data.remaining = Abilities.GetCooldownTimeRemaining(ability);
        data.activated = Abilities.IsActivated(ability);
        data.enabled = Abilities.GetLevel(ability) != 0;
        data.beingCast = Abilities.IsInAbilityPhase(ability);
        data.toggled = Abilities.IsToggle(ability) && Abilities.GetToggleState(ability);
        data.range = Abilities.GetCastRange(ability);

        if (data.cooldown == 0 || data.ready){
            data.cooldown = Abilities.GetCooldown(ability);
        }

        return data
    }

    this.GetAbilityCount = function() {
        return this.FilterAbilities().length;
    }

    this.IsSilenced = function() {
        return Entities.IsSilenced(this.entityId);
    }

    this.IsStunned = function() {
        return Entities.IsStunned(this.entityId);
    }

    this.ShowTooltip = function(element, data) {
        SetCurrentHoverSpell(data);

        var range = data.range.toString();

        if (data.range == 0) {
            range = "None";
        }

        element.SetDialogVariable("description", $.Localize("AbilityTooltip_" + data.name));
        element.SetDialogVariable("cooldown", data.cooldown.toFixed(1).toString());
        $.DispatchEvent("DOTAShowTextTooltip", element, $.Localize("AbilityTooltip", element))
    }

    this.HideTooltip = function() {
        $.DispatchEvent("DOTAHideTextTooltip");

        SetCurrentHoverSpell(null);
    }
}

function AbilityBar(elementId) {
    this.element = $(elementId);
    this.abilities = {};
    this.customIcons = {};

    this.SetProvider = function(provider) {
        this.provider = provider;
        this.Update();
    }

    this.Update = function() {
        var count = this.provider.GetAbilityCount();

        for (var i = 0; i < count; i++) {
            this.UpdateSlot(i);
        }

        for (slot in this.abilities) {
            if (slot >= count) {
                this.abilities[slot].Delete();
                delete this.abilities[slot];
            }
        }
    }

    this.UpdateSlot = function(slot) {
        var data = this.provider.GetAbilityData(slot);
        data.texture = GetTexture(data, this.customIcons);

        var ability = this.GetAbility(slot);
        ability.SetData(data);

        if (this.provider.IsSilenced && this.provider.IsStunned) {
            ability.SetDisabled(this.provider.IsSilenced(), this.provider.IsStunned());
        }
    }

    this.AddCustomIcon = function(abilityName, iconPath) {
        this.customIcons[abilityName] = iconPath;
    }

    this.GetAbility = function(slot) {
        if (!this.abilities[slot]) {
            var ability = new AbilityButton(this.element);

            this.abilities[slot] = ability;

            for (index in this.abilities) {
                if (index > slot) {
                    this.element.MoveChildBefore(this.abilities[slot].image, this.abilities[index].image)
                    break;
                }
            }
        }

        return this.abilities[slot];
    }

    this.RegisterEvents = function(clickable) {
        for (key in this.abilities) {
            var executeCapture = (function(bar, slot) {
                return function() {
                    // A bit of a hack, can't think of a better way for now
                    var ability = bar.GetAbility(slot);

                    Abilities.ExecuteAbility(ability.data.id, bar.provider.entityId, false);
                }
            } (this, key));

            var mouseOverCapture = (function(bar, slot) {
                return function() {
                    var ability = bar.GetAbility(slot);

                    bar.provider.ShowTooltip(ability.image, ability.data);
                }
            } (this, key));

            var mouseOutCapture = (function(bar) {
                return function() {
                    bar.provider.HideTooltip();
                }
            } (this));

            var ability = this.abilities[key];

            if (clickable) {
                ability.image.SetPanelEvent("onactivate", executeCapture);
            }
            
            ability.image.SetPanelEvent("onmouseover", mouseOverCapture);
            ability.image.SetPanelEvent("onmouseout", mouseOutCapture);
        }
    }
}

function AbilityButton(parent, hero, ability) {
    this.parent = parent;
    this.image = $.CreatePanel("Image", parent, "");
    this.image.AddClass("AbilityButton");
    this.ability = ability;

    this.inside = $.CreatePanel("Panel", this.image, "");
    this.inside.AddClass("AbilityButtonInside");

    this.shortcut = $.CreatePanel("Label", this.image, "");
    this.shortcut.AddClass("ShortcutText")

    this.cooldown = $.CreatePanel("Label", this.image, "");
    this.cooldown.AddClass("CooldownText");

    this.silence = $.CreatePanel("Panel", this.image, "");
    this.silence.AddClass("AbilitySilenced");

    this.stun = $.CreatePanel("Panel", this.image, "");
    this.stun.AddClass("AbilityStunned");

    this.data = {};

    this.SetData = function(data) {
        if (this.data.texture != data.texture) {
            this.image.SetImage(data.texture);
        }

        if (this.data.key != data.key) {
            this.shortcut.text = data.key;
        }

        if (this.data.cooldown != data.cooldown ||
            this.data.ready != data.ready ||
            this.data.remaining != data.remaining ||
            this.data.activated != data.activated) {
            this.SetCooldown(data.remaining, data.cooldown, data.ready, data.activated);
        }

        this.image.SetHasClass("AbilityBeingCast", data.beingCast);
        this.image.SetHasClass("AbilityButtonToggled", data.toggled);

        this.data = data;
    }

    this.SetCooldown = function(remaining, cd, ready, activated) {
        if (ready && activated) {
            this.image.SetHasClass("AbilityButtonEnabled", true);
            this.image.SetHasClass("AbilityButtonDeactivated", false);
            this.image.SetHasClass("AbilityButtonOnCooldown", false);
        }

        if (!ready){
            this.image.SetHasClass("AbilityButtonEnabled", false);
            this.image.SetHasClass("AbilityButtonDeactivated", false);
            this.image.SetHasClass("AbilityButtonOnCooldown", true);
        }

        if (!activated) {
            this.image.SetHasClass("AbilityButtonEnabled", false);
            this.image.SetHasClass("AbilityButtonDeactivated", true);
            this.image.SetHasClass("AbilityButtonOnCooldown", false);
        }

        var progress = (-360 * (remaining / cd)).toString();
        var text = cd.toFixed(1);

        if (!ready){
            text = remaining.toFixed(1);
        }

        if (cd == 0 || !activated) {
            progress = 0;
            text = "";
        }

        this.inside.style.clip = "radial(50% 50%, 0deg, " + progress + "deg)";
        this.cooldown.text = text;
    }

    this.SetDisabled = function(silenced, stunned) {
        this.silence.style.opacity = (silenced && !stunned) ? "1.0" : "0.0";
        this.stun.style.opacity = stunned ? "1.0" : "0.0";
    }

    this.Delete = function() {
        this.image.visible = false;
        this.image.DeleteAsync(0);
    }

    this.SetDisabled(false, false);
}
