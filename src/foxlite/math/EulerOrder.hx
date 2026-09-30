package foxlite.math;

#if !foxlite_polymod abstract #else class #end EulerOrder #if !foxlite_polymod (Int) from Int to Int #end {
	/**
		Roll -> Yaw -> Pitch

		This is the default rotation order for objects
	**/
	public inline static final ZYX = 0;

	/**
		Roll -> Pitch -> Yaw

		This is the rotation order for cameras, respects XY view rotation
	**/
	public inline static final ZXY = 1;
}