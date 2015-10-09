function Buff(parent) {
	this.element = $.CreatePanel("Image", parent, "");
	this.element.AddClass("Buff");
	this.element.data = {};

	this.SetVisible = function(visible) {
		this.element.SetHasClass("HiddenBuff", !visible);
	}

	this.SetDataFromBuffId = function(entityId, buffId) {
		var texture = Buffs.GetTexture(entityId, buffId);

		if (texture != data.texture) {
			data.texture = texture;
			this.element.SetImage(texture);
		}
	}
}

function BuffBar(elementId) {
	this.element = $(elementId);
	this.buffs = [];

	this.SetEntity = function(entityId) {
		this.entityId = entityId;

		this.Update();
	}

	this.FilterBuffs = function() {
		var count = this.Entities.GetNumBuffs(this.entityId);
		var result = [];

		for (var i = 0; i < count; i++) {
			var buffId = Entities.GetBuff(entityId, i);

			if (Buffs.IsHidden(this.entityId, buffId)) {
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
			buff.SetDataFromBuffId(this.entityId, id);
			buff.SetVisible(true);
		}

		for (var i = this.buffs.length; i < buffIds.length; i++) {
			this.buffs[i].SetVisible(false);
		}
	}
}