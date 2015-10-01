function Bar(parent){
	this.element = $.CreatePanel("Panel", parent, undefined);
	this.element.AddClass("HealthBar");

	this.SetAlive = function(alive) {
		this.element.SetHasClass("HealthBarDead", !alive);
	}
}

function HealthBar(elementId, hero) {
	this.element = $(elementId);
	this.heroId = hero;
	this.bars = [];
	this.currentHealth = Entities.GetMaxHealth(this.heroId)

	for (var i = 0; i < this.currentHealth; i++) {
		var bar = new Bar(this.element);
		this.bars.push(this.bars);
	}

	this.Update = function(){
		this.currentHealth = Math.round(Entities.GetHealth(this.heroId));
		for (int i = 0; i < this.bars.length; i++) {
			this.bars[i].SetAlive(this.currentHealth >= i);
		}
	}

	this.Damage = function(){
		this.bars[this.currentHealth].SetAlive(false);
		this.currentHealth--;
	}

	this.Heal = function(){
		this.bars[this.currentHealth - 1].SetAlive(true);
		this.currentHealth++;
	}

	this.Kill = function(){
		for (var bar of this.bars) {
			bar.SetAlive(false);
		}
	}

	this.Update();
}