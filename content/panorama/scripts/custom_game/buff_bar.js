function ShowBuffTooltip(element, entityId, buffId) {
	var isEnemy = Entities.IsEnemy(entityId);
	$.DispatchEvent("DOTAShowBuffTooltip", element, entityId, buffId, isEnemy);
}

function HideBuffTooltip() {
	$.DispatchEvent("DOTAHideBuffTooltip");
}

function Buff(parent) {
	this.element = $.CreatePanel("Image", parent, "");
	this.element.AddClass("Buff");
	this.timeText = $.CreatePanel("Label", this.element, "");
	this.timeText.AddClass("BuffTimeText");
	this.data = {};

	this.SetVisible = function(visible) {
		this.element.SetHasClass("HiddenBuff", !visible);
	}

	this.SetDataFromBuffId = function(entityId, buffId, customIcons) {
		var texture = Buffs.GetTexture(entityId, buffId);
		var debuff = Buffs.IsDebuff(entityId, buffId);
		var remaining = Math.max(0, Buffs.GetRemainingTime(entityId, buffId));


		if (texture != this.data.texture) {
			this.data.texture = texture;

			var textureData = {};
			textureData.texture = texture;
			textureData.name = Abilities.GetAbilityName(Buffs.GetAbility(entityId, buffId));
			this.element.SetImage(GetTexture(textureData, customIcons));
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