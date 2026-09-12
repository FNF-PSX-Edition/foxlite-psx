package foxlite.mesh.buffer;

import foxlite.polyfill.TypedArray;
import foxlite.renderer.FoxRenderer;
import openfl.display3D.Context3D;
import lime.graphics.opengl.GL;
import lime.utils.ArrayBufferView;
import lime.utils.DataPointer;

class FoxVertexBuffer {
	
	public var id:lime.graphics.opengl.GLBuffer;
	public var usage:Int;
	public var count:Int;
	public var components:Int;
	public var stride:Int = 0;
	public var bytesPerElement:Int = 0;
	public var type:Int = 0;

	/**
		Used at render time, if enabled, values from the byte/short/int range will be normalized from -1 to 1 
		(or 0 to 1 in the case of unsigned)
	**/
	public var normalized:Bool = false;

	var context:Context3D;

	/**
		Holder data for this buffer, disabled by default so it saves memory
	**/
	public var data:ArrayBufferView;

	/**
		@param elements The total element count
		@param dataPerVertex How many elements per vertex for the attribute
	**/
	public function new(elements:Int, dataPerVertex:Int, dynamicUsage:Bool=false) {
		context = FoxRenderer.getContext();
		count = elements;
		components = dataPerVertex;
		id = GL.createBuffer();
		usage = dynamicUsage ? context.gl.DYNAMIC_DRAW : context.gl.STATIC_DRAW;
	}

	public function uploadFromTypedArray(data:ArrayBufferView) {
		var gl = context.gl;
		this.data = data;

		#if !js
		type = switch(data.type) {
			case TypedArray.Int8: gl.BYTE;
			case TypedArray.Int16: gl.SHORT;
			case TypedArray.Int32: gl.INT;
			case TypedArray.Uint8, 
				 TypedArray.Uint8Clamped: gl.UNSIGNED_BYTE;
			case TypedArray.Uint16: gl.UNSIGNED_SHORT;
			case TypedArray.Uint32: gl.UNSIGNED_INT;
			case TypedArray.Float32: gl.FLOAT;
			default: throw "Invalid data";
		}

		bytesPerElement = switch(data.type) {
			case TypedArray.Int16, TypedArray.Uint16: 
				2;
			case TypedArray.Int32, TypedArray.Uint32, TypedArray.Float32: 
				4;
			default: 1;
		}
		#else
		// There's gotta be a better way
		if(data is js.lib.Int8Array) type = gl.BYTE;
		else if(data is js.lib.Int16Array) type = gl.SHORT;
		else if(data is js.lib.Int32Array) type = gl.INT;
		else if(data is js.lib.Uint8Array || data is js.lib.Uint8ClampedArray) type = gl.UNSIGNED_BYTE;
		else if(data is js.lib.Uint16Array) type = gl.UNSIGNED_SHORT;
		else if(data is js.lib.Uint32Array) type = gl.UNSIGNED_INT;
		else if(data is js.lib.Float32Array) type = gl.FLOAT;
		else throw "Invalid data";

		bytesPerElement = js.Syntax.code("this.data.BYTES_PER_ELEMENT");
		#end

		
		stride = components * bytesPerElement;

		bindAndUpload();
		if(!FoxRenderer.preserveGLBufferData) this.data = null;
	}

	function bindAndUpload() {
		var gl = context.gl;
		context.__bindGLArrayBuffer(id);
		gl.bufferData(gl.ARRAY_BUFFER, data, usage);
	}

	public function updateFromTypedArray(data:ArrayBufferView, byteOffset:Int=0) {
		var gl = context.gl;
		context.__bindGLArrayBuffer(id);
		#if foxlite_polymod
		#if lime_webgl
		GL.bufferSubDataWEBGL(gl.ARRAY_BUFFER, byteOffset, data);
		#else
		GL.bufferSubData(gl.ARRAY_BUFFER, byteOffset, data.length, DataPointer.fromArrayBufferView(data));
		#end
		#else
		gl.bufferSubData(gl.ARRAY_BUFFER, byteOffset, data);
		#end
	}

	public function dispose() {
		GL.deleteBuffer(id);
	}
}