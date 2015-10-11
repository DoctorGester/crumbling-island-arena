function Bar(parent){
	this.element = $.CreatePanel("Panel", parent, "");
	this.element.AddClass("HealthBar");

	this.SetAlive = function(alive) {
		this.element.SetHasClass("HealthBarDead", !alive);
	}

	this.Delete = function() {
		this.element.DeleteAsync(0);
	}
}

function HealthBar(elementId) {
	this.element = $(elementId);
	this.bars = [];
	this.currentHealth = 0;
	this.entityId = 0;

	this.SetEntity = function(entityId) {
		this.entityId = entityId;
		this.currentHealth = Math.round(Entities.GetHealth(this.entityId));

		var maxHealth = Entities.GetMaxHealth(entityId)

		for (var i = this.bars.length; i < maxHealth; i++) {
			var bar = new Bar(this.element);

			this.bars.push(bar);
		}

		if (this.bars.length > maxHealth) {
			var removed = this.bars.splice(maxHealth, this.bars.length - maxHealth);

			for (var element of removed) {
				element.Delete();
			}
		}

		this.Update();
	}

	this.Update = function(){
		this.currentHealth = Math.round(Entities.GetHealth(this.entityId));

		for (var i = 0; i < this.bars.length; i++) {
			this.bars[i].SetAlive(this.currentHealth > i);
		}
	}

	this.Damage = function(){
		this.bars[this.currentHealth - 1].SetAlive(false);
		this.currentHealth--;
	}

	this.Heal = function(){
		this.bars[this.currentHealth].SetAlive(true);
		this.currentHealth++;
	}

	this.Kill = function(){
		for (var bar of this.bars) {
			bar.SetAlive(false);
		}
	}
}