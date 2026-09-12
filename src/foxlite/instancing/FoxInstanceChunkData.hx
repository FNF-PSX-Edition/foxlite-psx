package foxlite.instancing;

import foxlite.mesh.buffer.FoxVertexBuffer;
import haxe.io.Bytes;
import lime.utils.Float32Array;
import openfl.display3D.Context3D;

class FoxInstanceChunkData {
	public var buffer:Float32Array;
	public var glBuffer:FoxVertexBuffer;

	public function new() {}

	// -------------------------------------------------------
	public var bytes:Bytes;

	public inline function setFloat(pos:Int, v:Float):Void {
		#if (js || !foxlite_polymod)
		buffer[pos] = v;
		#else
		bytes.setFloat(pos<<1, v);
		#end
	}

	public inline function getFloat(pos:Int):Float {
		#if (js || !foxlite_polymod)
		return buffer[pos];
		#else
		return bytes.getFloat(pos<<1);
		#end
	}
	// -------------------------------------------------------

	public function reallocate(context:Context3D, size:Int) {
		glBuffer?.dispose();
		glBuffer = new FoxVertexBuffer(size, 4, true); //context.createVertexBuffer(size, 4, cast 0);
		
		buffer = new Float32Array(size*4);
		#if js
		// js handles bytes differently, we use this instead for Bytes.blit()
		bytes = Bytes.ofData(buffer.buffer);
		#else
		bytes = cast buffer.buffer;
		#end
	}

	public function dispose() {
		glBuffer?.dispose();
		buffer = null;
		bytes = null;
	}
}