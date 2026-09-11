package foxlite;

import foxlite.flixel.FoxExtendableBasic;
import foxlite.group.FoxGroup;

/**
	Like `FoxScene`, but it only updates a `FoxGroup` (no rendering ever happens).

	Use this if you only want classes that require updating by foxlite (such as `FoxAnimationPlayer`)-
**/
class FoxOfflineScene extends FoxExtendableBasic {

	public var foxGroup:FoxGroup = new FoxGroup();

	/**
		An array of `FoxCamera`.

		They won't render anything in a `FoxOfflineScene`, but can still update their
		projection and view matrices
	**/
	public var foxCameras:Array<FoxCamera> = [];

	public override function update(elapsed:Float) {
		for(cam in foxCameras) if(cam.active) cam.update(elapsed);
		foxGroup.update(elapsed);
	}

	public inline function add(member:FoxBasic) {
		foxGroup.add(member);
	}

	public inline function insert(pos:Int, member:FoxBasic) {
		foxGroup.insert(pos, member);
	}

	public inline function remove(member:FoxBasic) {
		foxGroup.remove(member);
	}

	public override function destroy() {
		foxGroup.destroy();
		foxCameras = null;
		super.destroy();
	}
}