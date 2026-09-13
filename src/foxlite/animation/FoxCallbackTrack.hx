package foxlite.animation;

import haxe.ds.StringMap;
import foxlite.animation.FoxAnimationTrack;

#if !foxlite_polymod
abstract FoxTrackCall(Array<Dynamic>) {
	public function new(name:String, ?arguments:Array<Dynamic>) {
		this = [name, arguments ?? []];
	}
}
#end

/**
	This is a variation of FoxAnimationTrack that allows for calling a keyframe as a function.
**/
class FoxCallbackTrack extends FoxAnimationTrack #if !foxlite_polymod <FoxTrackCall> #end {

	/**
		A map of callbacks used for this track.

		Add a frame following this format:
		`addFrame(<time>, [<callbackName>, [<arguments>]], ...)`
	**/
	public var callbacks:Map<String, Dynamic> = new StringMap();
}