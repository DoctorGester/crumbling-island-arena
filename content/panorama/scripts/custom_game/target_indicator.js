var dummy = "npc_dota_hero_wisp";
var indicator = null;
var lastAbility = -1;
var hoverAbility = -1;
var lastHoverAbility = -1;
var targetingIndicators = {};
var hoverIndicators = {};
var indicatorTypes = {};
var hoverTypes = {};
var hoverIndicator = null;
var guidedAbility = -1;
var castedAbility = -1;

const globalThis = this;

function GetNumber(value, or, unit) {
    if (!value) {
        return or;
    }

    if (IsNumeric(value)) {
        return value;
    }

    const context = Object.create(globalThis);
    context.unit = unit;

    return evaluateExpressionNode(new Jsep(value).parse(), context)
}

indicatorTypes[null] = function(data, unit) {
    this.Update = function(position){}
    this.Delete = function(){}
};

indicatorTypes["TARGETING_INDICATOR_DIRECTION_GLOBAL"] = function(data, unit) {
    this.particle = Particles.CreateParticle("particles/targeting/global_target.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, unit);

    this.Update = function(position){
        var pos = Vector.FromArray(position);
        var dir = pos.minus(Vector.FromArray(Entities.GetAbsOrigin(unit))).normalize();
        pos = pos.add(dir.scale(500)).toArray();

        Particles.SetParticleControl(this.particle, 0, position);
        Particles.SetParticleControl(this.particle, 1, pos);
    };

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

indicatorTypes["TARGETING_INDICATOR_LINE"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/line.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit);

    this.Update = function(cursor){
        var to = UpdateLine(this.particle, this.unit, this.data, cursor);
        var result = to.minus(Vector.FromArray(Entities.GetAbsOrigin(unit))).normalize().scale(150).add(to);
        Particles.SetParticleControl(this.particle, 2, result);
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

indicatorTypes["TARGETING_INDICATOR_ARC"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/arc.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, unit);

    this.Update = function(position){
        var arc = GetNumber(data.Arc, null, unit);

        if (arc) {
            var from = Vector.FromArray(Entities.GetAbsOrigin(this.unit));
            UpdateArc(this, this.particle, from, position, arc, GetNumber(data.ArcWidth, 50, unit));
        }
    };

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

indicatorTypes["TARGETING_INDICATOR_AOE"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/aoe.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, unit);
    Particles.SetParticleControl(this.particle, 1, [ GetNumber(data.Radius, 0, unit), 0, 0 ]);

    this.arc = GetNumber(data.Arc, null, unit);

    if (this.arc) {
        this.arcParticle = Particles.CreateParticle("particles/targeting/arc.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, unit);
    }

    this.Update = function(position){
        Particles.SetParticleControl(this.particle, 0, ClampPosition(Vector.FromArray(position), this.unit, this.data));

        if (this.arc) {
            var from = Vector.FromArray(Entities.GetAbsOrigin(this.unit));
            UpdateArc(this, this.arcParticle, from, position, this.arc, GetNumber(data.ArcWidth, 25, unit));
        }
    };

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);

        if (this.arc) {
            Particles.DestroyParticleEffect(this.arcParticle, false);
            Particles.ReleaseParticleIndex(this.arcParticle);
        }
    }
};

indicatorTypes["TARGETING_INDICATOR_RANGE"] = function(data, unit) {
    this.offset = GetNumber(data.Offset, 0, unit);
    this.unit = unit;

    var attach = ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW;

    if (this.offset) {
        attach = ParticleAttachment_t.PATTACH_ABSORIGIN;
    }

    this.particle = Particles.CreateParticle("particles/targeting/range.vpcf", attach, unit);

    this.Update = function(cursor){
        Particles.SetParticleControl(this.particle, 1, [ GetNumber(data.Radius, 0, this.unit), 0, 0 ]);

        this.offset = GetNumber(data.Offset, 0, unit);

        if (this.offset) {
            cursor = Vector.FromArray(cursor);
            var pos = Vector.FromArray(Entities.GetAbsOrigin(this.unit));
            cursor.z = 0;
            pos.z = 0;

            var result = cursor.minus(pos).normalize().scale(this.offset).add(pos);

            Particles.SetParticleControl(this.particle, 0, result);
        }
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

indicatorTypes["TARGETING_INDICATOR_THICK_LINE"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/thick_line.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit);

    this.Update = function(cursor){
        UpdateLine(this.particle, this.unit, this.data, cursor);

        Particles.SetParticleControl(this.particle, 2, [ GetNumber(data.Width, 0, this.unit), 0, 0 ]);
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

indicatorTypes["TARGETING_INDICATOR_CONE"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/cone.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit);

    this.Update = function(cursor){
        UpdateLine(this.particle, this.unit, this.data, cursor);

        Particles.SetParticleControl(this.particle, 2, [ GetNumber(data.Width, 0, this.unit), 0, 0 ]);
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};


indicatorTypes["TARGETING_INDICATOR_HALF_CIRCLE"] = function(data, unit) {
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/half_circle.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit);

    this.Update = function(position){
        Particles.SetParticleControl(this.particle, 1, position);
        Particles.SetParticleControl(this.particle, 2, [ GetNumber(data.Radius, 0, this.unit), 0, 0 ]);
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

indicatorTypes["TARGETING_INDICATOR_LINE_EMBER"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/line.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit);

    this.FindRemnant = function(){
        for (var unit of Entities.GetAllEntitiesByClassname("npc_dota_creature")) {
            if (unit != this.unit && Entities.GetUnitName(unit) == "ember_remnant" && GetPlayerOwnerID(unit) == GetPlayerOwnerID(this.unit)) {
                return unit;
            }
        }

        return null;
    }

    var remnant = this.FindRemnant();
    if (remnant != null) {
        this.remnant = remnant;
        this.remnantParticle = Particles.CreateParticle("particles/targeting/line.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, remnant);
    }

    this.Update = function(cursor){
        var to = UpdateLine(this.particle, this.unit, this.data, cursor);
        var result = to.minus(Vector.FromArray(Entities.GetAbsOrigin(unit))).normalize().scale(150).add(to);
        Particles.SetParticleControl(this.particle, 2, result);

        if (this.remnant && !Entities.IsValidEntity(this.remnant)) {
            this.remnant = null;

            Particles.DestroyParticleEffect(this.remnantParticle, false);
            Particles.ReleaseParticleIndex(this.remnantParticle);

            this.remnantParticle = null;
        }

        if (this.remnantParticle && this.remnant) {
            var to = UpdateLine(this.remnantParticle, this.remnant, this.data, cursor);
            var result = to.minus(Vector.FromArray(Entities.GetAbsOrigin(this.remnant))).normalize().scale(150).add(to);
            Particles.SetParticleControl(this.remnantParticle, 2, result);
        }
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);

        if (this.remnantParticle) {
            Particles.DestroyParticleEffect(this.remnantParticle, false);
            Particles.ReleaseParticleIndex(this.remnantParticle);
        }
    }
};

indicatorTypes["TARGETING_INDICATOR_TINKER_LASER"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/thick_line.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, unit);

    this.Update = function(cursor){
        UpdateLine(this.particle, this.unit, this.data, cursor);

        var pos = Vector.FromArray(Entities.GetAbsOrigin(unit));
        var forward = Vector.FromArray(Entities.GetForward(unit));

        Particles.SetParticleControl(this.particle, 0, pos.add(new Vector(forward.y, -forward.x, 0).scale(96)))
        Particles.SetParticleControl(this.particle, 2, [ GetNumber(data.Width, 0, this.unit), 0, 0 ]);
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

indicatorTypes["TARGETING_INDICATOR_FROM_LINE_WITH_START_OFFSET"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/line.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, unit);

    this.Update = function(cursor){
        var abs = Vector.FromArray(Entities.GetAbsOrigin(unit));
        var dir = Vector.FromArray(cursor).minus(abs).normalize();

        var nd = new Vector(dir.y, -dir.x).scale(80);
        var offset = abs.add(nd);
        var updatedDirection = Vector.FromArray(cursor).minus(offset).normalize();

        cursor = Vector.FromArray(cursor).toArray();

        var to = UpdateLineFromPos(this.particle, this.unit, this.data, cursor, offset);
        var result = updatedDirection.scale(150).add(to);
        Particles.SetParticleControl(this.particle, 0, offset);
        Particles.SetParticleControl(this.particle, 2, result);
    };

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

indicatorTypes["TARGETING_INDICATOR_AM_DASH"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/line.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, unit);
    this.particle2 = Particles.CreateParticle("particles/targeting/line.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, unit);

    this.Update = function(cursor){
        this.UpdateLine(cursor, this.particle, 120);
        this.UpdateLine(cursor, this.particle2, -120);
    }

    this.UpdateLine = function(cursor, particle, offset) {
        var to = Vector.FromArray(cursor);
        to.z = 0;

        var pos = Vector.FromArray(Entities.GetAbsOrigin(unit));
        pos.z = 0;

        var forward = to.minus(pos).normalize();

        var offsetStart = pos.add(new Vector(forward.y, -forward.x, 0).scale(offset));

        var result = to.minus(Vector.FromArray(Entities.GetAbsOrigin(this.unit))).normalize().scale(150).add(to);
        Particles.SetParticleControl(particle, 0, offsetStart)
        Particles.SetParticleControl(particle, 1, forward.scale(450).add(offsetStart));
        Particles.SetParticleControl(particle, 2, forward.scale(600).add(offsetStart));
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);

        Particles.DestroyParticleEffect(this.particle2, false);
        Particles.ReleaseParticleIndex(this.particle2);
    }
};

indicatorTypes["TARGETING_INDICATOR_WK_W"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.subIndicators = [];

    for (var i = 0; i < 3; i++) {
        this.subIndicators.push(new indicatorTypes["TARGETING_INDICATOR_AOE"](data, unit));
    }

    this.Update = function(position){
        var i = -1;

        position = Vector.FromArray(position);

        for (var indicator of this.subIndicators) {
            var angle = Math.PI / 1.5 * i;
            var resultTarget = position.add(new Vector(Math.cos(angle) * 220, Math.sin(angle) * 220, 0));

            indicator.Update(resultTarget);
            i++;
        }
    };

    this.Delete = function(){
        for (var indicator of this.subIndicators) {
            indicator.Delete();
        }
    }
};

indicatorTypes["TARGETING_INDICATOR_TINY_W"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particles = [];
    this.arcParticles = [];
    this.arc = GetNumber(data.Arc, null, unit);

    this.Update = function(position){
        position = ClampPosition(Vector.FromArray(position), this.unit, this.data);

        const usingUltimate = HasModifier(unit, "modifier_tiny_r");
        const heroPosition = Vector.FromArray(Entities.GetAbsOrigin(unit));
        const dir = position.minus(heroPosition);
        const dist = dir.length2d();
        const tilt = 1 - dist / 2400.0;
        const totalBounces = 2;

        for (var i = -1; i <= 1; i++) {
            if (!usingUltimate && i !== 0) {
                for (var bounce = 0; bounce <= totalBounces; bounce++) {
                    var arrayIndex = ((i + 1) * (totalBounces + 1)) + bounce;

                    if (this.particles[arrayIndex]) {
                        Particles.DestroyParticleEffect(this.particles[arrayIndex], false);
                        Particles.ReleaseParticleIndex(this.particles[arrayIndex]);
                        this.particles[arrayIndex] = null;
                    }

                    if (this.arcParticles[arrayIndex]) {
                        Particles.DestroyParticleEffect(this.arcParticles[arrayIndex], false);
                        Particles.ReleaseParticleIndex(this.arcParticles[arrayIndex]);
                        this.arcParticles[arrayIndex] = null;
                    }
                }

                continue;
            }

            for (var bounce = 0; bounce <= totalBounces; bounce++) {
                var divider = Math.pow(2, bounce);
                var arrayIndex = ((i + 1) * (totalBounces + 1)) + bounce;
                var an = Math.atan2(dir.y, dir.x) + (0.9 * i * tilt);
                var rotated = new Vector(Math.cos(an), Math.sin(an));
                var retarget = heroPosition;
                var previous;

                for (var j = 0; j <= bounce; j++) {
                    previous = retarget.copy();
                    retarget = retarget.add(rotated.scale(dist / Math.pow(2, j)));
                }

                if (!this.particles[arrayIndex]) {
                    this.particles[arrayIndex] = Particles.CreateParticle("particles/targeting/aoe.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, unit);
                    Particles.SetParticleControl(this.particles[arrayIndex], 1, [ GetNumber(data.Radius, 0, unit), 0, 0 ]);

                    this.arcParticles[arrayIndex] = Particles.CreateParticle("particles/targeting/arc.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, unit);
                }

                Particles.SetParticleControl(this.particles[arrayIndex], 0, retarget);

                UpdateArc(this, this.arcParticles[arrayIndex], previous, retarget, this.arc / divider, GetNumber(data.ArcWidth, 25, unit));
            }
        }
    };

    this.Delete = function(){
        for (var i = 0; i < this.particles.length; i++) {
            if (this.particles[i]) {
                Particles.DestroyParticleEffect(this.particles[i], false);
                Particles.ReleaseParticleIndex(this.particles[i]);
            }

            if (this.arcParticles[i]) {
                Particles.DestroyParticleEffect(this.arcParticles[i], false);
                Particles.ReleaseParticleIndex(this.arcParticles[i]);
            }
        }
    }
};

function ClampPosition(to, unit, data, from) {
    var pos = from || Vector.FromArray(Entities.GetAbsOrigin(unit));

    pos.z = 32;
    to.z = 32;

    var length = to.minus(pos).length();
    var newLength = Clamp(length, GetNumber(data.MinLength, 0, unit), GetNumber(data.MaxLength, Number.MAX_VALUE, unit));

    if (length != newLength) {
        length = newLength;
        to = to.minus(pos).normalize().scale(length).add(pos);
    }

    return to;
}

function UpdateLineFromPos(particle, unit, data, cursor, pos) {
    var to = ClampPosition(Vector.FromArray(cursor), unit, data, pos);

    Particles.SetParticleControl(particle, 1, to);

    return to;
}

function UpdateLine(particle, unit, data, cursor) {
    return UpdateLineFromPos(particle, unit, data, cursor, Vector.FromArray(Entities.GetAbsOrigin(unit)));
}

indicatorTypes["TARGETING_INDICATOR_DUSA_SNAKE"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/dusa_snake.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit);

    this.Update = function(cursor){
        var to = Vector.FromArray(cursor);
        var dir = to.minus(Vector.FromArray(Entities.GetAbsOrigin(unit))).normalize();
        var pos = Vector.FromArray(Entities.GetAbsOrigin(unit));
        var to = Vector.FromArray(cursor);

        var length = to.minus(pos).length();
        var newLength = Clamp(length, GetNumber(data.MinLength, 0, unit), GetNumber(data.MaxLength, Number.MAX_VALUE, unit));

        if (length != newLength) {
            length = newLength;
            to = to.minus(pos).normalize().scale(length).add(pos);
        }

        var center = to.minus(pos).normalize().scale(length / 2).add(pos);

        Particles.SetParticleControlTransformForward(this.particle, 1, to, [dir.y, -dir.x, 0])
        Particles.SetParticleControl(this.particle, 2, to.add(dir.scale(150).rotate2d(-0.75)));
        Particles.SetParticleControlTransformForward(this.particle, 3, center, [dir.y, -dir.x, 0])
    }

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);
    }
};

indicatorTypes["TARGETING_INDICATOR_LINE_GYRO"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particles = [];

    for (var i = 0; i < 3; i++) {
        this.particles.push(Particles.CreateParticle("particles/targeting/line.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, unit));
    }

    this.Update = function(cursor){
        var index = -1;

        for (var particle of this.particles) {
            var abs = Vector.FromArray(Entities.GetAbsOrigin(unit));
            var dir = Vector.FromArray(cursor).minus(abs);
            var len = dir.length();
            dir = dir.normalize();
            var angle = Math.atan2(dir.y, dir.x) + index * 0.3;
            var retargetCursor = new Vector(Math.cos(angle), Math.sin(angle)).scale(len).add(abs).toArray();

            var to = UpdateLine(particle, this.unit, this.data, retargetCursor);
            var result = to.minus(abs).normalize().scale(150).add(to);
            Particles.SetParticleControl(particle, 2, result);

            index++;
        }
    };

    this.Delete = function(){
        for (var particle of this.particles) {
            Particles.DestroyParticleEffect(particle, false);
            Particles.ReleaseParticleIndex(particle);
        }
    };
};

indicatorTypes["TARGETING_INDICATOR_ANTIMAGE_Q"] = function(data, unit) {
    this.data = data;
    this.unit = unit;
    this.particle = Particles.CreateParticle("particles/targeting/line_target_curved.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, unit);
    this.particle2 = Particles.CreateParticle("particles/targeting/line_target_curved.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, unit);

    this.Update = function(cursor){
        var to = Vector.FromArray(cursor);
        var pos = Vector.FromArray(Entities.GetAbsOrigin(unit));
        var length = to.minus(pos).length();
        var min = GetNumber(data.MinLength, 0, unit);
        var max = GetNumber(data.MaxLength, Number.MAX_VALUE, unit);
        var newLength = Clamp(length, min, max);

        if (length != newLength) {
            length = newLength;
            to = to.minus(pos).normalize().scale(length).add(pos);
        }

        var prog = (newLength - min) / (max - min);

        this.UpdateParticle(pos, to, this.particle, 1, prog);
        this.UpdateParticle(pos, to, this.particle2, -1, prog);
    };

    this.UpdateParticle = function(pos, to, particle, side, prog) {
        var dir = to.minus(pos).normalize();
        pos = pos.add(new Vector(side * dir.y, side * -dir.x).scale(100));

        var length = to.minus(pos).length();
        var newLength = Clamp(length, GetNumber(data.MinLength, 0, unit), GetNumber(data.MaxLength, Number.MAX_VALUE, unit));

        if (length != newLength) {
            length = newLength;
            to = to.minus(pos).normalize().scale(length).add(pos);
        }

        var r = side * 0.8 + (-side * Math.exp(prog - 1));
        var rot = new Vector(side * dir.y, side * -dir.x, 0).rotate2d(r);

        Particles.SetParticleControl(particle, 0, pos);
        Particles.SetParticleControlTransformForward(particle, 1, to, [rot.x, rot.y, 0])
        Particles.SetParticleControl(particle, 2, to.add(dir.scale(150).rotate2d(side * 1.2 + r)));
    };

    this.Delete = function(){
        Particles.DestroyParticleEffect(this.particle, false);
        Particles.ReleaseParticleIndex(this.particle);

        Particles.DestroyParticleEffect(this.particle2, false);
        Particles.ReleaseParticleIndex(this.particle2);
    }
};

function UpdateArc(indicator, particle, from, position, targetHeight, width) {
    var fr = from.copy();
    var to = UpdateLineFromPos(particle, indicator.unit, indicator.data, position, fr);
    var len = to.minus(fr).length();

    // Don't ask why, I don't know
    fr.z = to.z + 2;

    var target = targetHeight;

    if (target > len) {
        target = len;
    }

    var rel = target / len;
    var val =  Math.max(1, len * rel);

    Particles.SetParticleControl(particle, 0, fr);
    Particles.SetParticleControl(particle, 1, to);
    Particles.SetParticleControl(particle, 2, [ width, 0, 0 ]);
    Particles.SetParticleControl(particle, 3, [ 0, 0, val ]);
}

function UpdatePosition() {
    var cursor = GameUI.GetCursorPosition();
    var position = GameUI.GetScreenWorldPosition(cursor);

    if (position && indicator) {
        indicator.Update(position);
    }
}

function UpdateHoverPosition() {
    var unit = Players.GetLocalPlayerPortraitUnit();
    var pos = Entities.GetAbsOrigin(unit);

    if (pos && hoverIndicator) {
        pos = Vector.FromArray(pos);

        var facing = Vector.FromArray(Entities.GetForward(unit)).scale(1, 1, 0).normalize(); // Yay!
        var result = pos.add(facing.scale(1000));

        hoverIndicator.Update(result);
    }
}

function UpdateTargetIndicator(){
    $.Schedule(1 / 144, UpdateTargetIndicator);

    var unit = Players.GetLocalPlayerPortraitUnit();
    var active = Abilities.GetLocalPlayerActiveAbility();

    if (active == -1) {
        active = guidedAbility;
    }

    if (!Entities.IsAlive(unit)) {
        active = -1;
    }

    var newHover = hoverAbility;
    var data = targetingIndicators[Abilities.GetAbilityName(active)];

    // TODO fix this hack
    if (hoverAbility == -1) {
        if (HasModifier(unit, "modifier_gyro_w")) {
            newHover = Entities.GetAbilityByName(unit, "gyro_w_sub");
        }

        if (HasModifier(unit, "modifier_sniper_r")) {
            newHover = Entities.GetAbilityByName(unit, "sniper_r");
        }
    }

    if (active != lastAbility) {
        lastAbility = active;

        if (indicator) {
            indicator.Delete();
            indicator = null;
        }

        if (data && data.Type) {
            indicator = new indicatorTypes[data.Type](data, unit);
            UpdatePosition(); // It's a bug, blame valve
        }
    } else {
        UpdatePosition();
    }

    if (data && (data.DisplayRange == "1" || data.DisplayRange == "true")) {
        newHover = active;
    }

    if (lastHoverAbility != newHover) {
        lastHoverAbility = newHover;

        if (hoverIndicator) {
            hoverIndicator.Delete();
            hoverIndicator = null;
        }

        if (newHover != -1) {
            var hoverData = hoverIndicators[Abilities.GetAbilityName(newHover)];

            if (hoverData && hoverData.Type) {
                hoverIndicator = new indicatorTypes[hoverData.Type](hoverData, unit);
                UpdateHoverPosition();
            }
        }
    } else {
        UpdateHoverPosition();
    }
}

function SetCurrentHoverSpell(spell){
    if (spell) {
        hoverAbility = spell.id;
    } else {
        hoverAbility = -1;
    }
}

function SetGuidedAbility(ability) {
    guidedAbility = ability;
}

function SetCastedAbility(ability) {
    castedAbility = ability;
}

function GetGyroRocketDistance(unit) {
    var m = FindModifier(unit, 'modifier_gyro_w');
    var elapsedTime = m ? Math.min(4.5, Buffs.GetElapsedTime(unit, m)) : 0;

    return 300 + elapsedTime * 250
}

UpdateTargetIndicator();

SubscribeToNetTableKey("main", "targetingIndicators", true, function(data){
    targetingIndicators = data;
});

SubscribeToNetTableKey("main", "hoverIndicators", true, function(data){
    hoverIndicators = data;
});
