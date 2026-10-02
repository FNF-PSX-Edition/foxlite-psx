package foxlite.instancing;

import haxe.io.Bytes;
import foxlite.polyfill.TypedArray;
import foxlite.math.FoxMathUtil;
import foxlite.mesh.buffer.FoxVertexMultiBuffer;
import foxlite.renderer.FoxRenderer;
import flixel.util.FlxColor;
import lime.utils.Float32Array;
import openfl.display3D.Context3D;
import openfl.geom.Matrix3D;
import openfl.geom.Vector3D;

class FoxInstanceData {

	public var data:FoxVertexMultiBuffer = new FoxVertexMultiBuffer(0, 0, true);
	var _data(get, never):Float32Array;

	inline function get__data():Float32Array {
		return cast data.data;
	}

	var __tmpBuffer = new Float32Array(16);
	var _bytes:Bytes;

	// Temporary matrix stuffs
	var __tempMatrix:Matrix3D = new Matrix3D();

	public var context:Context3D;

	public function new() {
		context = FoxRenderer.getContext();
		#if js
		// js handles bytes differently, we use this instead for Bytes.blit()
		_bytes = Bytes.ofData(__tmpBuffer.buffer);
		#else
		_bytes = cast __tmpBuffer.buffer;
		#end
	}

	public function reallocate(size:Int) {
		data.clearRegions();
		data.dispose();
		
		var buffer = TypedArray.Float32ArrayN(size*4*16); // elements * vec4 * 16

		final bytesPerElement = 4; // float
		final byteLength = 4 * bytesPerElement; // 4 components
		final stride = 4 * byteLength; // 4 chunks

		data.addRegion(4, stride, 0); // column 0
		data.addRegion(4, stride, byteLength); // column 1
		data.addRegion(4, stride, byteLength*2); // column 2
		data.addRegion(4, stride, byteLength*3); // color

		// Initialize
		size *= 16;
		var i:Int = 0, j:Int = 1, k:Int = 2;
		while(i < size) {
			buffer[i+12] = 1; 
			buffer[i+13] = 1;
			buffer[i+14] = 1;
			buffer[i+15] = 1; // color [R, G, B, A] Tilt your head to the left to see the matrix layout

			buffer[i+10] = 1; // col 2 [0, 0, 1, 0]
			buffer[i+5]  = 1; // col 1 [0, 1, 0, 0]
			buffer[i  ]  = 1; // col 0 [1, 0, 0, 0]
			i += 16;
		}

		data.uploadFromTypedArray(buffer);
		FoxRenderer.allocationsThisFrame += 2;
	}

	public function setInstanceTransform(pos:Int, transform:Matrix3D) {
		pos *= 16;
		var a = transform.rawData.__array;
		/*
		* We're writing it as a transposed 3x4 matrix:
		*  0  1  2  X
		*  4  5  6  X
		*  8  9 10  X
		* 12 13 14  X
		*/
		var i:Int = 0;
		for(p in pos...pos+3) {
			_data[p  ] = a[i  ];
			_data[p+4] = a[i+4];
			_data[p+8] = a[i+8];
			++i;
		}
		_data[pos+3] = a[12];
		_data[pos+7] = a[13];
		_data[pos+11] = a[14];
	}

	public function setInstanceTransformSeparate(pos:Int, ?position:Vector3D, ?rotation:Vector3D, ?scale:Vector3D) {
		FoxMathUtil.transformMatrix(__tempMatrix, position ?? FoxMathUtil.ZERO, rotation ?? FoxMathUtil.ZERO, scale ?? FoxMathUtil.ONE);
		setInstanceTransform(pos, __tempMatrix);
	}

	public function getInstanceTransform(pos:Int):Matrix3D {
		pos *= 16;
		var transform = new Matrix3D();
		var a = transform.rawData.__array;

		// Note: We're getting the transposed version
		var i:Int = 0;
		for(p in pos...pos+3) {
			a[i  ] = _data[p  ];
			a[i+4] = _data[p+4];
			a[i+8] = _data[p+8];
			++i;
		}
		a[12] = _data[pos+3];
		a[13] = _data[pos+7];
		a[14] = _data[pos+11];
		FoxRenderer.allocationsThisFrame += 1;
		return transform;
	}

	public function setInstanceColor(pos:Int, col:Vector3D) {
		pos *= 16;
		_data[pos+12] = col.x;
		_data[pos+13] = col.y;
		_data[pos+14] = col.z;
		_data[pos+15] = col.w;
	}

	public function setInstanceFlxColor(pos:Int, col:FlxColor) {
		pos *= 16;
		_data[pos+12] = col.redFloat;
		_data[pos+13] = col.greenFloat;
		_data[pos+14] = col.blueFloat;
		_data[pos+15] = col.alphaFloat;
	}

	public function getInstanceColor(pos:Int):Vector3D {
		pos *= 16;
		FoxRenderer.allocationsThisFrame += 1;
		return new Vector3D(
			_data[pos+12],
			_data[pos+13],
			_data[pos+14],
			_data[pos+15]
		);
	}

	public function getInstanceFlxColor(pos:Int):FlxColor {
		pos *= 16;
		return FlxColor.fromRGBFloat(
			_data[pos+12],
			_data[pos+13],
			_data[pos+14],
			_data[pos+15]
		);
	}

	public function flushAll() {
		data.updateFromTypedArray(_data);
	}

	public function flushInstance(instance:Int) {
		var byteOffset:Int = instance * 64; // 16 components x 4 bytes

		// Blit instance data bytes to temp, then upload
		_bytes.blit(0, #if js Bytes.ofData(_data.buffer) #else cast _data.buffer #end, byteOffset, 64);
		data.updateFromTypedArray(__tmpBuffer, byteOffset);
	}

	public function flushRegion(fromInstance:Int, toInstance:Int) {
		var length:Int = (toInstance - fromInstance) * 16;
		var byteLength:Int = 4 * length;
		var byteOffset:Int = fromInstance*64;

		var buffer:Float32Array = __tmpBuffer; // we can reuse this
		if(length != 16) buffer = TypedArray.Float32ArrayN(length); // allocate if big

		var bytes:Bytes = #if js Bytes.ofData(buffer.buffer); #else cast buffer.buffer; #end
		
		bytes.blit(0, cast _data.buffer, byteOffset, byteLength);
		data.updateFromTypedArray(buffer, byteOffset);

		FoxRenderer.allocationsThisFrame += 1;
	}

	public function destroy() {
		data.dispose();
	}
}