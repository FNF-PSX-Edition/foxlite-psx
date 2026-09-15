package foxlite.culling;

import haxe.ds.ReadOnlyArray;
import openfl.geom.Matrix3D;
import openfl.geom.Vector3D;
import foxlite.culling.BoundingBox;

/**
	Reference: https://learnopengl.com/Guest-Articles/2021/Scene/Frustum-Culling
**/
class FrustumPlanes {

	/**
		An array containing 6 planes, each for one side of the frustum.
		Since Vector3D already has a 4th component, we can just use that for distance
	**/
	public var planes:ReadOnlyArray<Vector3D> = [
		new Vector3D(), new Vector3D(), new Vector3D(),
		new Vector3D(), new Vector3D(), new Vector3D()
	];

	/**
		@param projection Create frustum planes from a projection matrix
	**/
	public function new(?projection:Matrix3D) {
		if(projection != null) fromProjection(projection);
	}

	/**
		Stores each plane of the projection frustum for culling calculations

		Because the purpose is merely for frustum culling, we abs() all plane
		normals here to prevent doing that for every check

		If you want robust frustum collision detection, use the (upcoming) physics engine instead
	**/
	public function fromProjection(projection:Matrix3D) {
		final m = projection.rawData.__array;

		planes[0].setTo(Math.abs(m[3]+m[0]), Math.abs(m[7]+m[4]), Math.abs(m[11]+m[8])); // left
		planes[0].w = m[15]+m[12];

		planes[1].setTo(Math.abs(m[3]-m[0]), Math.abs(m[7]-m[4]), Math.abs(m[11]-m[8])); // right
		planes[1].w = m[15]-m[12];

		planes[2].setTo(Math.abs(m[3]+m[1]), Math.abs(m[7]+m[5]), Math.abs(m[11]+m[9])); // bottom like my bf
		planes[2].w = m[15]+m[13];

		planes[3].setTo(Math.abs(m[3]-m[1]), Math.abs(m[7]-m[5]), Math.abs(m[11]-m[9])); // top like me
		planes[3].w = m[15]-m[13];

		planes[4].setTo(Math.abs(m[3]+m[2]), Math.abs(m[7]+m[6]), Math.abs(m[11]+m[10])); // near
		planes[4].w = m[15]+m[14];
		
		planes[5].setTo(Math.abs(m[3]-m[2]), Math.abs(m[7]-m[6]), Math.abs(m[11]-m[10])); // far
		planes[5].w = m[15]-m[14];

	}

	public function copyFrom(other:FrustumPlanes) {
		for(i in 0...6) {
			planes[i].copyFrom(other.planes[i]);
			planes[i].w = other.planes[i].w;
		}
	}

	/**
		Tests if the plane is intersecting a `BoundingBox`
		
		[AABB Plane intersection](https://gdbooks.gitbooks.io/3dcollisions/content/Chapter2/static_aabb_plane.html)
	**/
	public inline function testAABBPlane(plane:Vector3D, box:BoundingBox):Bool {
		var dist = plane.dotProduct(box.center) - plane.w; // signed distance
		var    r = plane.dotProduct(box.extents); // projection interval radius
		return dist <= r;
	}

	/**
		Tests if a `BoundingBox` is inside the frustum
	**/
	public function overlapsBox(box:BoundingBox):Bool {
		for(plane in planes) {
			if(!testAABBPlane(plane, box)) return false;
		}
		return true;
	}
}