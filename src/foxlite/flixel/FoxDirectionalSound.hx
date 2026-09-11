package foxlite.flixel;

import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import foxlite.math.FoxMathUtil;
import flixel.sound.FlxSound;
import openfl.geom.Vector3D;

@:dox(hide) typedef PropagationQueue = {
	targetTime:Float,
	currentTime:Float,
	queuedStartTime:Float,
	?queuedEndTime:Float
}

/**
	A `FlxSound` that pans left and right based on the camera position in 3D.

	__Note:__ Due to OpenAL limitations, this only works with sounds that doesn't have stereo audio channels.
**/
class FoxDirectionalSound extends FoxObject {

	public var sound:FlxSound;
	var attenObj:FlxObject = new FlxObject(); // Tracker attenuator object

	/**
		The strength of the stereo panning.

		A value of 1.0 means pan fully left or right,

		A value of 0.5 means pan left, while right is still audible, and viceversa.

		A value of 0.0 means no panning, and negative values inverts the panning.
	**/
	public var panStrength:Float = 0.85;

	/**
		The sound range in world units.

		Note: The attenuation power follows the [Inverse Square Law](https://en.wikipedia.org/wiki/Inverse-square_law) for realistic effects.
	**/
	public var range:Float = 100;

	/**
		Pitch up/down the sound based on its velocity towards/away from the camera.

		It's the same effect when an ambulance is passing in front of you; its siren sounds
		pitched up when it's getting closer, and pitched down when it's going away

		Keep in mind that this effect overwrites `pitch`, use `dopplerPitchOffset` to use a custom pitch.
	**/
	public var dopplerStrength:Float = 0;
	public var dopplerPitchOffset:Float = 0;

	/**
		The speed the sound travels at sea level in *meters per second* (`m/s`)

		To disable it, set it to 0
	**/
	public var propagationSpeed:Float = 343;

	var prevDistance:Float = 0; // Previous frame distance to calculate doppler shift
	var playDistance:Float = 0; // Distance from camera that was set since the last `play()` call

	/**
		The queued sound parameters for propagation
	**/
	public var queued:PropagationQueue = {
		currentTime: 0,
		targetTime: 0,
		queuedStartTime: 0
	};

	/**
		The index of the camera to follow in the scene.
	**/
	public var cameraIndex:Int = 0;

	public function new(target:FlxSound) {
		super();
		name = "FoxDirectionalSound";
		sound = target;
	}

	public override function update(dt:Float) {
		super.update(dt);
		if(sound == null) return;
		var camera = scene.foxCameras[cameraIndex];
		var viewPos = camera?.getScreenPoint(globalPosition);
		if(viewPos == null) return;

		// Because projection can be mirrored if behind the camera, make sure we keep it absolute
		var signW = FlxMath.signOf(viewPos.w);
		var panX = FoxMathUtil.glslClamp(viewPos.x * signW, -1, 1);

		// Stereo pan
		sound.pan = panX - panX*(1 - panStrength);

		// Attenuation
		var distance:Float = Vector3D.distance(globalPosition, camera.position);
		attenObj.x = Math.pow(distance, 2);
		sound.proximity(0, 0, attenObj, range*range, false);

		// Doppler
		var distanceDelta:Float = (distance - prevDistance);
		prevDistance = distance;

		if(dopplerStrength != 0) sound.pitch = (dopplerPitchOffset + 1) - distanceDelta * (60*dt) * dopplerStrength;

		// Dynamic sound propagation
		if(playDistance != 0) {
			queued.currentTime += dt;
			queued.currentTime -= getDelayFromDistance(distanceDelta); // Play it sooner or later based on camera movement
			if(queued.currentTime >= queued.targetTime) _play();
		}
	}

	/**
		Returns the delay in seconds the sound would take to reach the camera to be heard

		This distance can change based on propagationSpeed and if the camera has been moved 
		since the last `play()` call
	**/
	inline function getDelayFromDistance(dist:Float) {
    	return dist / Math.abs(propagationSpeed);
	}

	/**
		Plays the sound. Unlike `FlxSound.play()`, this function takes into account realistic sound propagation
		and will queue the sound.

		__Note:__ Calling this will force the sound to play from the beginning, if you want to pause/resume the sound
		use its `play()` function directly and after the timer has been finished, if you need to stop the sound or the queue,
		call `stop()`
	**/
	public function play(startTime:Float=0, ?endTime:Float) {
		var camera = scene.foxCameras[cameraIndex];
		var pos:Vector3D = camera?.position;
		if(pos == null) pos = globalPosition;
		
		playDistance = propagationSpeed == 0 ? 0 : Vector3D.distance(globalPosition, pos);

		if(playDistance == 0) {
			sound?.play(true, startTime, endTime);
			return;
		}

		queued.queuedStartTime = startTime;
		queued.queuedEndTime = endTime;

		queued.targetTime = getDelayFromDistance(playDistance);
		queued.currentTime = 0;
		sound?.stop();
	}

	public function stop() {
		sound?.stop();
		playDistance = 0;
	}

	function _play() {
		sound?.play(true, queued.queuedStartTime, queued.queuedEndTime);
		playDistance = 0;
	}

	public override function destroy() {
		sound?.destroy();
		attenObj.destroy();
		super.destroy();
	}
}