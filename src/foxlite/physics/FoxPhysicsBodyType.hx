package foxlite.physics;

#if lime_box3d
#if !foxlite_polymod abstract #else class #end FoxPhysicsBodyType #if !foxlite_polymod (Int) from Int to Int #end {

	/**
		This body will become an immovable object by physics.
		
		Zero mass and zero velocity, can be manually positioned and will
		not be affected by other physics objects.
	**/
	public inline static final STATIC = 0;

	/**
		This body will become an unstoppable object by physics.
		
		Zero mass, but a velocity can be specified, and will not be affected
		by other physics objects.
	**/
	public inline static final KINEMATIC = 1;

	/**
		This body will become dynamic and will be affected by other objects.

		Positive mass, velocity is determined by forces.
	**/
	public inline static final DYNAMIC = 2;

	@:from public static function fromString(type:String):FoxPhysicsBodyType {
		type = type.toLowerCase();
		return switch(type) {
			case "static": FoxPhysicsBodyType.STATIC;
			case "kinematic": FoxPhysicsBodyType.KINEMATIC;
			case "dynamic": FoxPhysicsBodyType.DYNAMIC;
			default: throw "physics body type invalid enum";
		}
	}

	@:to public static function toString(type:FoxPhysicsBodyType):String {
		return switch(type) {
			case FoxPhysicsBodyType.STATIC: "static";
			case FoxPhysicsBodyType.KINEMATIC: "kinematic";
			case FoxPhysicsBodyType.DYNAMIC: "dynamic";
			default: throw "physics body type invalid enum";
		}
	}
}
#end