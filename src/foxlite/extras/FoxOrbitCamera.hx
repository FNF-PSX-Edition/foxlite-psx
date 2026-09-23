package foxlite.extras;

import Reflect;
import foxlite.animation.FoxLerp;
import foxlite.math.FoxMathUtil;
import foxlite.extras.FoxFPSCamera;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import lime.math.Vector2;
import openfl.geom.Vector3D;

/**
	An extension of `FoxFPSCamera` that rotates around the origin instead of being
	in first person.

	The distance can be controlled with the mouse wheel.
**/
class FoxOrbitCamera extends FoxFPSCamera {

	/**
		Distance from the origin point
	**/
	public var distance:Float;

	/**
		When controlling distance with mouse wheel, this determines how much it
		increases and decreases
	**/
	public var distanceStep:Float = 0.5;

	/**
		Smooths out the distance transitions
	**/
	public var distanceSmoothed:Bool = true;

	public var distanceSmoothFactor:Float = 0.5;

	public var curDistance:Float = 0;

	public function new(dist:Float=-5, x:Float=0, y:Float=0, z:Float=0, bgColor:FlxColor=0x0, ortho:Bool=false, withLightData:Bool=true) {
		super(x, y, z, bgColor, ortho, withLightData);
		distance = dist;
	}

	public override function update(dt:Float) {
		super.update(dt);

		if(enableControls) {
			#if !FLX_NO_MOUSE
			distance -= distanceStep * FlxG.mouse.wheel;
			#end
		}

		var ddt:Float = Math.min(dt * 60 * distanceSmoothFactor, 1);
		if(distanceSmoothed) {
			curDistance = FoxLerp.lerp(curDistance, distance, ddt);
		}
		else curDistance = distance;

		// We can offset our Z view after it's been calculated, makes things ridiculously easy
		viewMatrix.appendTranslation(0, 0, -curDistance);
		// Since we're just offseting distances we kinda don't need to recalculate inverse directions, probably
	}
}