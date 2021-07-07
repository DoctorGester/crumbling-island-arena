var modifiersWithStacks = [
    "modifier_charges",
    "modifier_attack_speed",
    "modifier_wk_q",
    "modifier_pudge_meat",
    "modifier_qop_r",
    "modifier_am_damage",
    "modifier_gyro_q",
    "modifier_gyro_q_slow",
    "modifier_cm_a",
    "modifier_ta_r",
    "modifier_wr_a",
    "modifier_ursa_fury",
    "modifier_undying_q_health",
    "modifier_pa_q",
    "modifier_drow_q",
    "modifier_nevermore_a",
    "modifier_tree_heal",
    "modifier_rune_blue",
    "modifier_pa_a",
    "modifier_void_e_counter",
    "modifier_slark_a"
];

function ShowBuffTooltip(element, entityId, buffId) {
    var isEnemy = Entities.IsEnemy(entityId);
    $.DispatchEvent("DOTAShowTextTooltip", element, $.Localize("ModifierTooltip_" + Buffs.GetName(entityId, buffId)))
}

function HideBuffTooltip() {
    $.DispatchEvent("DOTAHideTextTooltip");
}

function Buff(parent) {
    this.element = $.CreatePanel("Image", parent, "");
    this.element.AddClass("Buff");
    this.element.SetScaling("stretch-to-cover-preserve-aspect");
    this.timeText = $.CreatePanel("Label", this.element, "");
    this.timeText.AddClass("BuffTimeText");
    this.stacksText = $.CreatePanel("Label", this.element, "");
    this.stacksText.AddClass("BuffStacksText");
    this.data = {};

    this.SetVisible = function(visible) {
        this.element.SetHasClass("HiddenBuff", !visible);
    }

    this.SetDataFromBuffId = function(entityId, buffId, customIcons) {
        var texture = Buffs.GetTexture(entityId, buffId);
        var debuff = Buffs.IsDebuff(entityId, buffId);
        var remaining = Math.max(0, Buffs.GetRemainingTime(entityId, buffId));
        var stacks = 0;

        if (_.contains(modifiersWithStacks, Buffs.GetName(entityId, buffId))) {
            stacks = Buffs.GetStackCount(entityId, buffId);
        }

        var textureData = {};
        textureData.texture = texture;
        textureData.name = Abilities.GetAbilityName(Buffs.GetAbility(entityId, buffId));

        texture = GetTexture(textureData, customIcons);

        if (texture != this.data.texture) {
            this.data.texture = texture;
            
            this.element.SetImage(texture);
        }

        if (debuff != this.data.debuff) {
            this.data.debuff = debuff;

            this.element.SetHasClass("PositiveBuff", !debuff);
            this.element.SetHasClass("NegativeBuff", debuff);
        }

        if (remaining != this.data.remaining) {
            if (remaining != 0) {
                this.timeText.text = remaining.toFixed(1);
            } else {
                this.timeText.text = "";
            }
        }

        if (stacks != this.data.stacks) {
            if (stacks != 0) {
                this.stacksText.text = stacks.toString();
            } else {
                this.stacksText.text = "";
            }
        }

        if (buffId != this.data.buffId || entityId != this.data.entityId) {
            this.data.buffId = buffId;
            this.data.entityId = entityId;

            var executeCapture = (function(buff) {
                return function() {
                    var alertBuff = GameUI.IsAltDown();
                    Players.BuffClicked(buff.data.entityId, buff.data.buffId, alertBuff);
                }
            } (this));

            var mouseOverCapture = (function(buff) {
                return function() {
                    ShowBuffTooltip(buff.element, buff.data.entityId, buff.data.buffId);
                }
            } (this));

            var mouseOutCapture = function() {
                HideBuffTooltip();
            };

            this.element.SetPanelEvent("onactivate", executeCapture);
            this.element.SetPanelEvent("onmouseover", mouseOverCapture);
            this.element.SetPanelEvent("onmouseout", mouseOutCapture);
        }
    }
}

function BuffBar(elementId) {
    this.element = $(elementId);
    this.buffs = [];
    this.customIcons = {};
    this.entityId = 0;

    this.AddCustomIcon = function(abilityName, iconPath) {
        this.customIcons[abilityName] = iconPath;
    }

    this.SetEntity = function(entityId) {
        this.entityId = entityId;

        this.Update();
    }

    this.FilterBuffs = function() {
        var count = Entities.GetNumBuffs(this.entityId);
        var result = [];

        for (var i = 0; i < count; i++) {
            var buffId = Entities.GetBuff(this.entityId, i);

            if (buffId == -1 || Buffs.IsHidden(this.entityId, buffId)) {
                continue;
            }

            result.push(buffId);
        }

        return result;
    }

    this.Update = function() {
        var buffIds = this.FilterBuffs();

        for (var i = 0; i < buffIds.length; i++) {
            var id = buffIds[i];

            if (i >= this.buffs.length) {
                this.buffs.push(new Buff(this.element));
            }

            var buff = this.buffs[i];
            buff.SetDataFromBuffId(this.entityId, id, this.customIcons);
            buff.SetVisible(true);
        }

        for (var i = buffIds.length; i < this.buffs.length; i++) {
            this.buffs[i].SetVisible(false);
        }
    }
}