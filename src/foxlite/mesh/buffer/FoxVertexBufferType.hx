package foxlite.mesh.buffer;

// How to create abstracts in Polymod: You don't!
// Surprisingly, this is valid in Haxe
#if !foxlite_polymod abstract #else class #end FoxVertexBufferType #if !foxlite_polymod (Int) from Int to Int #end {
	public inline static final VERTICES = 0;
	public inline static final UVS = 1;
	public inline static final NORMALS = 2;
	public inline static final TANGENTS = 3;
	public inline static final COLORS = 4;
	public inline static final WEIGHTS = 5;
	public inline static final BONE_INDICES = 6;
	public inline static final INDICES = 7;

	@:from public static function fromString(bufType:String):FoxVertexBufferType {
		bufType = bufType.toLowerCase();
		return switch(bufType) {
			case "vertices": FoxVertexBufferType.VERTICES;
			case "uvs": FoxVertexBufferType.UVS;
			case "normals": FoxVertexBufferType.NORMALS;
			case "tangents": FoxVertexBufferType.TANGENTS;
			case "colors": FoxVertexBufferType.COLORS;
			case "weights": FoxVertexBufferType.WEIGHTS;
			case "bone_indices": FoxVertexBufferType.BONE_INDICES;
			case "indices": FoxVertexBufferType.INDICES;
			default: throw "Invalid string value";
		}
	}

	@:to public static function toString(bufType:FoxVertexBufferType):String {
		return switch(bufType) {
			case FoxVertexBufferType.VERTICES: "vertices";
			case FoxVertexBufferType.UVS: "uvs";
			case FoxVertexBufferType.NORMALS: "normals";
			case FoxVertexBufferType.TANGENTS: "tangents";
			case FoxVertexBufferType.COLORS: "colors";
			case FoxVertexBufferType.WEIGHTS: "weights";
			case FoxVertexBufferType.BONE_INDICES: "bone_indices";
			case FoxVertexBufferType.INDICES: "indices";
			default: throw "Invalid enum type";
		}
	}
}