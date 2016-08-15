/*
 * Javascript implementation of a 3D vector. This vector class is immutable, meaning any operation
 * will return a new vector object instead of modifying an existing one.
 *
 * Usage:
 *
 * - Defining a vector:
 * var vec = new Vector( 1, 2, 3 );
 * var vec2 = new Vector( 2, 4, 5 );
 *
 * - Performing operations:
 * var vec3 = vec.add( vec2 );
 *
 * Available functionality:
 *
 * vec.add( vec2 ) - Add vec2 to vec.
 * vec.minus( vec2 ) - Subtract vec2 from vec.
 * vec.scale( s ) - Scale the vector by scalar s.
 * vec.length() - Get the length of the vector.
 * vec.normalize() - Normalize the vector.
 *
 * vec.dot( vec2 ) - The dot product of vec and vec2. - vec · vec2
 * vec.cross( vec2 ) - The cross product of vec and vec2. - vec x vec2
 *
 * vec.distanceTo( vec2 ) - Get the distance between vectors - same as vec.minus( vec2 ).length().
 * vec.scaleTo( l ) - Scale the vector to length l.
 *
 * Static functionality:
 *
 * Vector.FromArray( array ) - Create a vector from an array. Only accepts arrays with length 2 or 3.
 *
 * By: Perry
 */

 /* Constructor*/
function Vector( x, y, z ) {
    this.x = x || 0;
    this.y = y || 0;
    this.z = z || 0;
}

//Override the object's toString() method, unfortunately $.Msg does not use this.
Vector.prototype.toString = function() {
    return "Vector(" + this.x + ", " + this.y + ", " + this.z + ")";
}

//Create a vector from an array
Vector.FromArray = function( array ) {
    if (array instanceof Vector) { return array; }

    if ( array.length == 2 ) {
        return new Vector( array[0], array[1], 0 );
    } else if ( array.length == 3 ) {
        return new Vector( array[0], array[1], array[2] );
    } else {
        return new Vector( 0, 0, 0 );
    }
}

Vector.prototype.toArray = function(){
    return [ this.x, this.y, this.z ];
}

//Get the length of the vector
Vector.prototype.length = function(){
    return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
}

//Get the distance of this vector to another vector
Vector.prototype.distanceTo = function( v2 ) {
    return Math.sqrt( (v2.x-this.x)*(v2.x-this.x) + (v2.y-this.y)*(v2.y-this.y) + (v2.z-this.z)*(v2.z-this.z) );
}

//Subtract another vector from this vector
Vector.prototype.minus = function( v2 ) {
    return new Vector( this.x - v2.x, this.y - v2.y, this.z - v2.z );
}

//Add another vector to this vector
Vector.prototype.add = function( v2 ) {
    return new Vector( this.x + v2.x, this.y + v2.y, this.z + v2.z );
}

//Multiply this vector with a scalar
Vector.prototype.scale = function ( s ) {
    return new Vector( this.x * s, this.y * s, this.z * s );
}

//Return the current vector direction with some length
//Returns 0 vector if the length of this vector is 0
Vector.prototype.scaleTo = function ( s ) {
    var length = this.length();
    if (length == 0){
        return new Vector( 0, 0, 0 );   
    }
    else {
        return this.scale( s / length );    
    }
}

//Return the normalized vector of this vector
Vector.prototype.normalize = function() {
    var length = this.length();
    return new Vector( this.x / length, this.y / length, this.z / length );
}

//Return the dot product of this vector and another vector
Vector.prototype.dot = function( v2 ) {
    return this.x * v2.x + this.y * v2.y + this.z * v2.z;
}

//Return the cross product of this vector and another vector
Vector.prototype.cross = function( v2 ) {
    return new Vector(
            this.y * v2.z - this.z * v2.y,
            this.z * v2.x - this.x * v2.z,
            this.x * v2.y - this.y * v2.x 
    );
}

Vector.prototype.rotate2d = function(an) {
    return new Vector(
        this.x * Math.cos(an) - this.y * Math.sin(an),
        this.x * Math.sin(an) + this.y * Math.cos(an),
        this.z
    );
}