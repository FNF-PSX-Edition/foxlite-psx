package foxlite.mesh.buffer;

import foxlite.mesh.buffer.FoxVertexBuffer;
import lime.graphics.opengl.GL;

typedef VertexBufferRegion = {
	components:Int,
	offset:Int,
	stride:Int,
	normalized:Bool
}

/**
	An extension to `FoxVertexBuffer` to store multiple attributes in a single buffer
**/
class FoxVertexMultiBuffer extends FoxVertexBuffer {

	public var regions:Array<VertexBufferRegion> = [];

	/**
		Adds an attribute region for the vertex buffer

		__Note:__ The order of the regions should follow the order of attributes in your shader

		@param dataPerVertex How many elements per vertex for the attribute
		@param stride The number of bytes to skip to reach the next batch, usually calculated as `dataPerVertex*bytesPerElement` plus an offset
		@param offset The byte offset to where start reading the buffer
		@param normalized  if enabled, values from the byte/short/int range will be normalized from -1 to 1 
		(or 0 to 1 in the case of unsigned)
	**/
	public function addRegion(dataPerVertex:Int, stride:Int, offset:Int=0, normalized:Bool=false) {
		regions.push({
			components: dataPerVertex,
			offset: offset,
			stride: stride,
			normalized: normalized
		});
	}

	override function _uploadTask() {
		if(id == null) id = GL.createBuffer();
		bindAndUpload();
		//if(!FoxRenderer.preserveGLBufferData) this.data = null; // keep data
	}

	public inline function clearRegions() {
		regions.resize(0);
	}
}