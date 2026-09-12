package foxlite.mesh.buffer;

import lime.utils.DataPointer;
import lime.utils.ArrayBufferView;

class FoxIndexBuffer extends FoxVertexBuffer {
	
	override function bindAndUpload() {
		var gl = context.gl;
		context.__bindGLElementArrayBuffer(id);
		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, data, usage);
	}

	public override function updateFromTypedArray(data:ArrayBufferView, byteOffset:Int=0) {
		var gl = context.gl;
		context.__bindGLElementArrayBuffer(id);
		#if foxlite_polymod
		#if lime_webgl
		GL.bufferSubDataWEBGL(gl.ELEMENT_ARRAY_BUFFER, byteOffset, data);
		#else
		GL.bufferSubData(gl.ELEMENT_ARRAY_BUFFER, byteOffset, data.length, DataPointer.fromArrayBufferView(data));
		#end
		#else
		gl.bufferSubData(gl.ELEMENT_ARRAY_BUFFER, byteOffset, data);
		#end
	}
}