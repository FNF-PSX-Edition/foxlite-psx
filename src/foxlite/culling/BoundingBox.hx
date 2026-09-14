package foxlite.culling;

import foxlite.math.FoxMathUtil;
import foxlite.renderer.FoxRenderer;
import openfl.geom.Vector3D;
import openfl.geom.Matrix3D;

class BoundingBox {

	// Temporary bounds for calculations
	public static var __tempBounds:BoundingBox = new BoundingBox();
	public static var __tempBounds2:BoundingBox = new BoundingBox();
	
	public var center:Vector3D = new Vector3D();
	public var extents:Vector3D = new Vector3D();

	public function new(?min:Vector3D, ?max:Vector3D):Void {
		if(min != null && max != null) fromExtents(min, max);
		FoxRenderer.allocationsThisFrame += 3;
	}

	public function fromExtents(min:Vector3D, max:Vector3D):BoundingBox {
		// (min + max) / 2
		center.copyFrom(min);
		center.incrementBy(max);
		center.scaleBy(0.5);

		// (max - min) / 2
		extents.copyFrom(max);
		extents.decrementBy(min);
		extents.scaleBy(0.5);

		return this;
	}

	/**
		This merges two bounding boxes so they expand to cover their total volume

		This also moves the bounding box so the extents can be applied to the new volume
	**/
	public function expand(box:BoundingBox) {
		if(extents.equals(FoxMathUtil.ZERO)) {
			copyFrom(box);
			return;
		}
		final min = FoxMathUtil.__tempVector;
		final max = FoxMathUtil.__tempVector2;

		min.setTo(
			Math.min(center.x - extents.x, box.center.x - box.extents.x),
			Math.min(center.y - extents.y, box.center.y - box.extents.y),
			Math.min(center.z - extents.z, box.center.z - box.extents.z)
		);
		max.setTo(
			Math.max(center.x + extents.x, box.center.x + box.extents.x),
			Math.max(center.y + extents.y, box.center.y + box.extents.y),
			Math.max(center.z + extents.z, box.center.z + box.extents.z)
		);

		fromExtents(min, max);
	}
	
	public inline function copyFrom(box:BoundingBox) {
		center.copyFrom(box.center);
		extents.copyFrom(box.extents);
	}

	public function zero() {
		center.setTo(0, 0, 0);
		extents.setTo(0, 0, 0);
	}

	/**
		Transforms this bounding box to encapsulate an object's global transform.

		This can be very useful to determine the object's extents on-screen and do frustum culling

		@param transform The transform of the `FoxObject`
		@param output (Optional) Where to store the transformed result, if empty, a new `BoundingBox` will be created
	**/
	public function getTransformed(transform:Matrix3D, ?output:BoundingBox):BoundingBox {
		if(output == null) {
			output = new BoundingBox();
			FoxRenderer.allocationsThisFrame += 1;
		}

		// Translate to global position
		transform.transformVectorToOutput(center, output.center);

		// Account for scale and rotation (grows the extents for easy AABB checks)
		// The matrix already stores those combined so we can just take its magnitudes
		final a = transform.rawData.__array;
		output.extents.setTo(
			Math.abs(a[0]) * extents.x + Math.abs(a[4]) * extents.y + Math.abs(a[8])  * extents.z,
			Math.abs(a[1]) * extents.x + Math.abs(a[5]) * extents.y + Math.abs(a[9])  * extents.z,
			Math.abs(a[2]) * extents.x + Math.abs(a[6]) * extents.y + Math.abs(a[10]) * extents.z
		);
		return output;
	}
}