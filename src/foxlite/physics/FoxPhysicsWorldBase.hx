package foxlite.physics;

import foxlite.FoxBasic;

/**
	Implement your own physics world by extending this class
**/
class FoxPhysicsWorldBase extends FoxBasic {

	/**
		For a consistant and performant physics simulation, a fixed rate is used
		always regardless of framerate. This is 50hz by default, but you can change
		it if you need it.

		__Note:__ Setting this value above the game framerate will cause physics updates
		to be called more than once per frame, it's better to keep this value
		under 100 ticks per second and use physics interpolation instead.
	**/
	public var updateRate:Int = 50;

	/**
		This is the time passed between each physics step, this can be used to slow down or
		speed up the simulation while updating it at the same rate.
	**/
	public var timeStep:Float = 1/50;
	
	/**
		This is the amount of physics update ocurring between frames for accurate collision
		detection, a value of 4 is decent enough, but it can be increased or decreased for a
		tradeoff between accuracy and speed.
		
		Too low of a value can cause high-speed objects to go trough other objects or cause jittering.
	**/
	public var subSteps:UInt = 4;

	/**
		A function to call alongside `world_Step`

		Used in FoxScene to call member's `physicsUpdate()`
	**/
	public var onPhysicsUpdate:(dt:Float)->Void;

	var elapsedTime:Float = 0;

	public var timeSinceLastStep:Float = 0;
	public var currentTime:Float = 0;

	/**
		Initialize physics stuff here
	**/
	public function new() {
		super();
	}

	/**
		Steps the physics simulation.

		Internally, this has a delta counter so updates happen at a fixed rate.
		If the application update rate is lower than `updateRate`, more calls
		will happen per frame.

		@param dt The actual elapsed time for the application

		@returns The number of iteration steps needed for compensation. Can be 0, meaning
		no step is required this frame
	**/
	public function step(dt:Float):UInt {
		elapsedTime += dt;
		final rateMs:Float = 1/updateRate;
		var it:UInt = 0;
		while(elapsedTime >= rateMs) {
			elapsedTime -= rateMs;
			physicsStep(dt);
			if(onPhysicsUpdate != null) onPhysicsUpdate(timeStep);
			timeSinceLastStep = currentTime; // add subticks to this aswell?
			++it;
		}
		return it;
	}

	/**
		The physics engine step function
	**/
	public function physicsStep(dt:Float) {}

	public override function update(dt:Float) {
		super.update(dt);
		currentTime += dt;
		step(dt);
	}

	public override function destroy() {
		super.destroy();
	}
}