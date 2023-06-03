// AbilityDataProvider ->
//  GetAbilityData(slot)
//  GetAbilityCount()

function EmptyAbilityDataProvider() {
    this.GetAbilityData = function(slot) {
        return {};
    };

    this.GetAbilityCount = function() {
        return 0;
    }
}

function EntityAbilityDataProvider(entityId) {
    this.entityId = entityId;
    this.onlyCosmetic = false;

    this.FilterAbility = function(id) {
        var nl = DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE;
        var cosmetic = (Abilities.GetBehavior(id) & nl) == nl;

        return !Abilities.IsAttributeBonus(id) && Abilities.IsDisplayedAbility(id) && !Abilities.IsPassive(id) && cosmetic == this.onlyCosmetic;
    };

    this.FilterAbilities = function() {
        var abilities = [];
        var count = Entities.GetAbilityCount(this.entityId);
        var custom;

        for (var i = 0; i < count; i++) {
            var ability = Entities.GetAbility(this.entityId, i);

            if (this.FilterAbility(ability)) {
                if (EndsWith(Abilities.GetAbilityName(ability), "_a")) {
                    abilities.unshift(ability);
                } else if (Abilities.GetAbilityName(ability) == "ability_blink") {
                    custom = ability;
                } else {
                    abilities.push(ability);
                }
            }
        }

        if (custom) {
            abilities.push(custom);
        }

        return abilities;
    };

    this.SetOnlyCosmetic = function(only) {
        this.onlyCosmetic = only;
    };

    this.GetAbilityData = function(slot) {
        var ability = this.FilterAbilities()[slot];
        var data = {};
        var nl = DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE;
        var rootDisables = DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES;

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
        data.cosmetic = (Abilities.GetBehavior(ability) & nl) == nl;
        data.attack = EndsWith(Abilities.GetAbilityName(ability), "_a");
        data.custom = Abilities.GetAbilityName(ability) == "ability_blink";
        data.rootDisables = (Abilities.GetBehavior(ability) & rootDisables) == rootDisables;

        if (data.cooldown == 0 || data.ready){
            data.cooldown = Abilities.GetCooldown(ability);
        }

        return data
    };

    this.GetAbilityCount = function() {
        return this.FilterAbilities().length;
    };

    this.IsSilenced = function() {
        if (Entities.IsSilenced(this.entityId)) {
            return true;
        }

        for (var modifier in statusEffects) {
            if (statusEffects[modifier].token == "#StatusSilenced" && HasModifier(this.entityId, modifier)) {
                return true;
            }
        }

        if (HasModifier(this.entityId, "modifier_falling") || HasModifier(this.entityId, "modifier_jugger_q")) {
            return true;
        }

        return false;
    };

    this.IsStunned = function(ability) {
        var ignoreStunFlag = DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE;
        var ignoresStun = (Abilities.GetBehavior(ability) & ignoreStunFlag) == ignoreStunFlag;

        return Entities.IsStunned(this.entityId) && !ignoresStun;
    };

    this.IsDisarmed = function() {
        return Entities.IsDisarmed(this.entityId);
    };

    this.IsRooted = function() {
        return Entities.IsRooted(this.entityId);
    };

    this.ShowTooltip = function(element, data) {
        SetCurrentHoverSpell(data);

        AbilityTooltip(data, element);
    };

    this.HideTooltip = function() {
        $.DispatchEvent("DOTAHideTextTooltip");

        SetCurrentHoverSpell(null);
    }
}

function AbilityBar(elementId) {
    this.element = $(elementId);
    this.abilities = {};
    this.customIcons = {};
    this.customClasses = {};

    this.SetProvider = function(provider) {
        this.provider = provider;
        this.Update();
    };

    this.Update = function() {
        if (this.provider == null) {
            return;
        }

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
    };

    this.UpdateSlot = function(slot) {
        var data = this.provider.GetAbilityData(slot);
        data.texture = GetTexture(data, this.customIcons);

        var ability = this.GetAbility(slot);
        var prevCl = this.customClasses[ability.data.name];
        var cl = this.customClasses[data.name];

        ability.SetData(data);
        ability.SetCustomClass(prevCl, cl);

        if (this.provider.IsSilenced && this.provider.IsStunned && this.provider.IsRooted) {
            var rooted = this.provider.IsRooted() && data.rootDisables;
            ability.SetDisabled(this.provider.IsSilenced() && !data.attack && !data.custom, this.provider.IsStunned(data.id), rooted);
        }

        if (data.attack) {
            ability.SetDisarmed(this.provider.IsDisarmed());
        }
    };

    this.AddCustomIcon = function(abilityName, iconPath) {
        this.customIcons[abilityName] = iconPath;
    };

    this.AddCustomClass = function(abilityName, cl) {
        this.customClasses[abilityName] = cl;
    };

    this.GetAbility = function(slot) {
        if (!this.abilities[slot]) {
            var ability = new AbilityButton(this.element);

            this.abilities[slot] = ability;

            for (index in this.abilities) {
                if (index > slot) {
                    this.element.MoveChildBefore(this.abilities[slot].button, this.abilities[index].button)
                    break;
                }
            }
        }

        return this.abilities[slot];
    };

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

                    bar.provider.ShowTooltip(ability.button, ability.data);
                }
            } (this, key));

            var mouseOutCapture = (function(bar) {
                return function() {
                    bar.provider.HideTooltip();
                }
            } (this));

            var ability = this.abilities[key];

            if (clickable) {
                ability.button.SetPanelEvent("onactivate", executeCapture);
            }
            
            ability.button.SetPanelEvent("onmouseover", mouseOverCapture);
            ability.button.SetPanelEvent("onmouseout", mouseOutCapture);
        }
    }
}

function AbilityButton(parent, hero, ability) {
    this.parent = parent;
    this.button = $.CreatePanel("Button", parent, "")
    this.button.AddClass("AbilityButton");
    this.ability = ability;

    this.image = $.CreatePanel("Image", this.button, "");
    this.image.AddClass("AbilityButtonImage")

    this.custom = $.CreatePanel("Panel", this.image, "");

    this.inside = $.CreatePanel("Panel", this.image, "");
    this.inside.AddClass("AbilityButtonInside");

    this.shortcut = $.CreatePanel("Label", this.image, "");
    this.shortcut.AddClass("ShortcutText")

    this.cooldown = $.CreatePanel("Label", this.image, "");
    this.cooldown.AddClass("CooldownText");

    this.shineMask = $.CreatePanel("Panel", this.image, "");

    this.silence = $.CreatePanel("Panel", this.image, "");
    this.silence.AddClass("AbilitySilenced");

    this.stun = $.CreatePanel("Panel", this.image, "");
    this.stun.AddClass("AbilityStunned");

    this.data = {};

    this.SetData = function(data) {
        if (this.data.texture != data.texture && !data.cosmetic) {
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

        this.button.SetHasClass("AbilityBeingCast", data.beingCast);
        this.button.SetHasClass("AbilityButtonToggled", data.toggled);
        this.button.SetHasClass("AbilityAttack", data.attack);
        this.button.SetHasClass("AbilityCustom", data.custom);

        this.data = data;
    };

    this.SetCustomClass = function(prevCl, cl) {
        if (prevCl) {
            this.custom.SetHasClass(prevCl, false);
        }

        if (cl) {
            this.custom.SetHasClass(cl, true);
        }
    };

    this.SetCooldown = function(remaining, cd, ready, activated) {
        this.inside.SetHasClass("AbilityButtonInsideOnCooldown", !ready);

        if (ready && activated) {
            this.button.SetHasClass("AbilityButtonEnabled", true);
            this.button.SetHasClass("AbilityButtonDeactivated", false);
            this.button.SetHasClass("AbilityButtonOnCooldown", false);
        }

        if (!ready){
            this.button.SetHasClass("AbilityButtonEnabled", false);
            this.button.SetHasClass("AbilityButtonDeactivated", false);
            this.button.SetHasClass("AbilityButtonOnCooldown", true);
        }

        if (!activated) {
            this.button.SetHasClass("AbilityButtonEnabled", false);
            this.button.SetHasClass("AbilityButtonDeactivated", true);
            this.button.SetHasClass("AbilityButtonOnCooldown", false);
        }

        var progress = (-360 * (remaining / cd)).toString();
        var text = cd.toFixed(1);

        if (!ready){
            text = remaining.toFixed(1);
        }

        if (progress == 0) {
            progress = -360;
        }

        if (remaining == 0 && activated) {
            this.shineMask.AddClass("CooldownEndShine");
        } else {
            this.shineMask.RemoveClass("CooldownEndShine"); 
        }

        if (cd == 0 || !activated) {
            progress = 0;
            text = "";
        }

        this.inside.style.clip = "radial(50% 50%, 0deg, " + progress + "deg)";
        this.cooldown.text = text;
    };

    this.SetDisabled = function(silenced, stunned, rooted) {
        this.silence.style.opacity = (silenced && !stunned) ? "1.0" : "0.0";
        this.stun.style.opacity = stunned ? "1.0" : "0.0";
        this.button.SetHasClass("AbilityDisarmed", rooted);
    };

    this.SetDisarmed = function(disarmed) {
        this.button.SetHasClass("AbilityDisarmed", disarmed);
    };

    this.Delete = function() {
        this.button.visible = false;
        this.button.DeleteAsync(0);
    };

    this.SetDisabled(false, false, false);
}
