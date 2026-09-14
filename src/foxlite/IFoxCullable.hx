package foxlite;

// For future implementation: Used in FoxModel and FoxObjectGroup
#if !foxlite_polymod
interface IFoxCullable {
	/**
		If enabled, this will perform frustum culling, meaning this object will disable its rendering when it's not
		visible by the camera. If you have many many objects on-screen that shouldn't be visible off-screen,
		keep this enabled
	**/
	public var frustumCulling:Bool;

	/**
		If true, this object will not call `update()`. Keep in mind this will disable
		any logic you've put here if extending this class.
	**/
	public var deactivateWhenCulled:Bool;

	/**
		The scale for the meshes extents, increase this if your object gets culled too early
	**/
	public var cullMargin:Float;

	/**
		This value is set per-camera at draw time, indicating if the model has been culled

		To disable these calculations, set `frustumCulling` to disabled
	**/
	public var culled:Bool;

	/**
		If set, frustum culling will be tested for each mesh individually instead of the expanded
		bounding box, this can be more computationally expensive but it can help when you have many
		meshes inside a model that are far away from each other (i.e: big maps as a single OBJ model)

		__Note:__ This is currently not implemented
	**/
	//public var perMeshCulling:Bool = false;
}
#end