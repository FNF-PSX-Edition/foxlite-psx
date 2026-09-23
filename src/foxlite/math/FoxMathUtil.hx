package foxlite.math;

import haxe.ds.ReadOnlyArray;
import foxlite.polyfill.VectorFactory;
import foxlite.renderer.FoxRenderer;
import foxlite.texture.FoxCubemapSide;
import openfl.geom.Matrix3D;
import openfl.geom.Vector3D;

// If you're wondering why there's different names for each created matrix in the functions
// it's because for some reason if they have the same name, their values get overwriten
// even if they're in completely different scopes!!!!! 
// Edit: this has been written in version 0.8.1, after updating to 0.8.3, the issue was fixed

class FoxMathUtil {

	public inline static final degToRad =  0.0174532925199433;
	public inline static final radToDeg = 57.2957795130823209;
	public inline static final TAU = 	   6.2831853071795865; // PI * 2
	public inline static final PI_2 = 	   1.5707963267948967; // PI / 2
	public inline static final LN2 =   	   0.6931471805599453; // Math.log(2)

	/**
		Cache temporary vectors
	**/
	public static final __tempVector = new Vector3D();
	public static final __tempVector2 = new Vector3D();
	public static final __tempVector3 = new Vector3D();

	/**
		Cache temporary matrices
	**/
	public static final __tempMatrix = new Matrix3D();
	public static final __tempMatrix2 = new Matrix3D();

	/**
		Cached Identity values so no allocation happens when calling openfl's `Matrix3D.identity()`
	**/
	public static final MATRIX_IDENTITY = VectorFactory.Float([1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1]);

	// Vector3D Axes
	public static final RIGHT 	  = new Vector3D(1, 0, 0);
	public static final UP 		  = new Vector3D(0, 1, 0);
	public static final FORWARD	  = new Vector3D(0, 0, -1);
	public static final LEFT	  = new Vector3D(-1, 0, 0);
	public static final DOWN	  = new Vector3D(0, -1, 0);
	public static final BACK	  = new Vector3D(0, 0, 1);
	public static final ZERO 	  = new Vector3D(0, 0, 0);
	public static final ONE 	  = new Vector3D(1, 1, 1);

	/**
		A list of matrix directions corresponding to `FoxCubemapSide`.

		__Note:__ The offsets of the matrices can change so it represents positions aswell,
		if you want it to be at the origin, set `matrix.position` to `FoxMathUtil.ZERO`
	**/
	public static final MATRIX_DIRECTIONS:ReadOnlyArray<Matrix3D> = [
		new Matrix3D(), // right
		new Matrix3D(), // left
		new Matrix3D(), // top
		new Matrix3D(), // bottom
		new Matrix3D(), // back
		new Matrix3D() // front
	];

	public static function staticInit() {
		#if foxlite_polymod
		trace(degToRad, radToDeg, RIGHT, UP, FORWARD, LEFT, DOWN, BACK, ZERO, ONE, TAU, PI_2, __tempVector, __tempVector2, __tempVector3, MATRIX_IDENTITY, MATRIX_DIRECTIONS, __tempMatrix, __tempMatrix2);
		#end
		// Idk why some directions are inverted, but this seems to correspond to what foxlite uses
		MATRIX_DIRECTIONS[FoxCubemapSide.RIGHT].pointAt(ZERO, RIGHT, DOWN);
		MATRIX_DIRECTIONS[FoxCubemapSide.LEFT].pointAt(ZERO, LEFT, DOWN);
		MATRIX_DIRECTIONS[FoxCubemapSide.TOP].pointAt(ZERO, UP, BACK);
		MATRIX_DIRECTIONS[FoxCubemapSide.BOTTOM].pointAt(ZERO, DOWN, FORWARD);
		MATRIX_DIRECTIONS[FoxCubemapSide.BACK].pointAt(ZERO, BACK, UP);
		MATRIX_DIRECTIONS[FoxCubemapSide.FRONT].pointAt(ZERO, FORWARD, UP);
	}

	public static function perspectiveMatrix(mp:Matrix3D, fov:Float, aspect:Float, near:Float, far:Float):Matrix3D {
		var ZRANG = near - far;
		fov = 1 / Math.tan((fov * 0.5) * degToRad);
		
		mp.copyRawDataFrom(MATRIX_IDENTITY); // identity()
		var a = mp.rawData.__array;
		a[0] = fov / aspect;
		a[5] = fov;
		a[10] = -(-near - far) / ZRANG;
		a[11] = 2.0 * far * near / ZRANG;
		a[14] = -1;
		a[15] = 0;
		mp.transpose();
		FoxRenderer.allocationsThisFrame += 1;
		return mp;
	}

	public static function perspectiveMatrixClipFast(mp:Matrix3D, near:Float, far:Float):Matrix3D {
		var ZRANG = near - far;
		var a = mp.rawData.__array;
		a[10] = -(-near - far) / ZRANG;
		a[14] = 2.0 * far * near / ZRANG;
		return mp;
	}

	public static function createPerspective(fov:Float, aspect:Float, near:Float, far:Float):Matrix3D {
		FoxRenderer.allocationsThisFrame += 1;
		return perspectiveMatrix(new Matrix3D(), fov, aspect, near, far);
	}
	
	public static function orthogonalMatrix(mo:Matrix3D, size:Float, aspect:Float, near:Float, far:Float):Matrix3D {
		var right = size * 0.5;
		var left = -right;
		var top = size / aspect * 0.5;
		var bottom = -top;

		mo.copyRawDataFrom(MATRIX_IDENTITY); // identity()
		
		var a = mo.rawData.__array;
		a[0] = 2.0 / (right - left);
		a[3] = -((right + left) / (right - left));
		a[5] = 2.0 / (top - bottom);
		a[7] = -((top + bottom) / (top - bottom));
		a[10] = -2.0 / (far - near);
		a[11] = -((far + near) / (far - near));
		a[15] = 1;
		mo.transpose();
		FoxRenderer.allocationsThisFrame += 1;

		return mo;
	}

	public static function createOrthogonal(size:Float, aspect:Float, near:Float, far:Float):Matrix3D {
		FoxRenderer.allocationsThisFrame += 1;
		return orthogonalMatrix(new Matrix3D(), size, aspect, near, far);
	}

	// My brain hurts
	public static function transformMatrix(matTRS:Matrix3D, pos:Vector3D, rotEuler:Vector3D, scale:Vector3D):Matrix3D {
		matTRS.copyRawDataFrom(MATRIX_IDENTITY); // identity()
		if(!scale.equals(FoxMathUtil.ONE)) {
			FoxMathUtil.fastAppendScale(matTRS, scale.x, scale.y, scale.z);
		}

		if(rotEuler.z != 0) alloclessAppendRotation(matTRS, rotEuler.z, BACK);
		if(rotEuler.y != 0) alloclessAppendRotation(matTRS, rotEuler.y, UP);
		if(rotEuler.x != 0) alloclessAppendRotation(matTRS, rotEuler.x, RIGHT);
		matTRS.appendTranslation(pos.x, pos.y, pos.z);

		return matTRS;
	}

	public static function basisMatrix(matR:Matrix3D, rotEuler:Vector3D):Matrix3D {
		matR.copyRawDataFrom(MATRIX_IDENTITY); // identity()
		if(rotEuler.z != 0) alloclessAppendRotation(matR, rotEuler.z, BACK);
		if(rotEuler.y != 0) alloclessAppendRotation(matR, rotEuler.y, UP);
		if(rotEuler.x != 0) alloclessAppendRotation(matR, rotEuler.x, RIGHT);
		return matR;
	}

	public static function viewMatrix(matRT:Matrix3D, pos:Vector3D, rotEuler:Vector3D):Matrix3D {
		matRT.copyRawDataFrom(MATRIX_IDENTITY); // identity()
		matRT.appendTranslation(-pos.x, -pos.y, -pos.z);

		if(rotEuler.y != 0) alloclessAppendRotation(matRT, -rotEuler.y, UP);
		if(rotEuler.x != 0) alloclessAppendRotation(matRT, -rotEuler.x, RIGHT);
		if(rotEuler.z != 0) alloclessAppendRotation(matRT, -rotEuler.z, BACK);

		return matRT;
	}

	public static function viewMatrixFromTransform(output:Matrix3D, transform:Matrix3D):Matrix3D {
		output.copyRawDataFrom(MATRIX_IDENTITY); // identity()
		final pos = __tempVector;
		pos.copyFrom(transform.position);
		pos.negate();
		output.position = pos;

		// We also apply scale normalization to prevent weirdness when the camera transform has scale applied
		var rot = eulerFromMatrix(transform, __tempVector, scaleFromMatrix(transform, __tempVector2));
		rot.scaleBy(-1);
		
		if(rot.z != 0) alloclessAppendRotation(output, rot.z, BACK);
		if(rot.y != 0) alloclessAppendRotation(output, rot.y, UP);
		if(rot.x != 0) alloclessAppendRotation(output, rot.x, RIGHT);
		return output;
	}

	public static function createTransform(pos:Vector3D, rotEuler:Vector3D, scale:Vector3D):Matrix3D {
		FoxRenderer.allocationsThisFrame += 1;
		return transformMatrix(new Matrix3D(), pos, rotEuler, scale);
	}

	public static function createViewMatrix(pos:Vector3D, rotEuler:Vector3D):Matrix3D {
		FoxRenderer.allocationsThisFrame += 1;
		return viewMatrix(new Matrix3D(), pos, rotEuler);
	}

	public static function createBasisMatrix(rotEuler:Vector3D):Matrix3D {
		FoxRenderer.allocationsThisFrame += 1;
		return basisMatrix(new Matrix3D(), rotEuler);
	}

	/**
		Allocationless identity matrix (OpenFL allocates a new Vector)
	**/
	public inline static function fastIdentity(matrix:Matrix3D) {
		matrix.copyRawDataFrom(MATRIX_IDENTITY);
	}

	/**
		Allocationless transpose (OpenFL copies the whole Vector)
	**/
	public static function fastTranspose(matrix:Matrix3D):Matrix3D {
		final a = matrix.rawData.__array;
		var m1:Float = a[1], m2:Float = a[2], m3:Float = a[3],
			m4:Float = a[4], m6:Float = a[6], m7:Float = a[7],
			m8:Float = a[8], m9:Float = a[9], m11:Float = a[11],
			m12:Float = a[12], m13:Float = a[13], m14:Float = a[14];
		
		a[1] = m4; a[2] = m8; a[3] = m12;
		a[4] = m1; a[6] = m9; a[7] = m13;
		a[8] = m2; a[9] = m6; a[11] = m14;
		a[12] = m3; a[13] = m7; a[14] = m11;
		return matrix;
	}

	/**
		Allocationless scale append (OpenFL creates another matrix and vector from an array)

		Also with reduced operations by simplifying the rest of the matrix
	**/
	public static function fastAppendScale(matrix:Matrix3D, x:Float=1, y:Float=1, z:Float=1):Matrix3D {
		final a = matrix.rawData.__array;
		a[0] *= x;  a[1] *= y;  a[2] *= z;
		a[4] *= x;  a[5] *= y;  a[6] *= z;
		a[8] *= x;  a[9] *= y;  a[10] *= z;
		a[12] *= x; a[13] *= y; a[14] *= z;
		return matrix;
	}

	/**
		Allocationless rotation append (OpenFL creates another Matrix)

		__Note:__ Pivot point argument is no longer present, translate the matrix manually
		before and after rotation, this also simplifies calculations...

		__Note2:__ This makes use of the internal temporary matrix, make sure you're not
		overlapping it with itself as the input
	**/
	public static function alloclessAppendRotation(matrix:Matrix3D, radian:Float, axis:Vector3D) {
		var cos = Math.cos(radian);
		var sin = Math.sin(radian);
		var x:Float = axis.x, y:Float = axis.y, z:Float = axis.z;
		var x2:Float = x * x, y2:Float = y * y, z2:Float = z * z;
		var ls:Float = x2 + y2 + z2;
		if (ls != 0) {
			var l = Math.sqrt(ls);
			x /= l; y /= l; z /= l;
			x2 /= ls; y2 /= ls; z2 /= ls;
		}
		var ccos = 1 - cos;
		final m = __tempMatrix2;
		final d = m.rawData.__array;
		d[0] = x2 + (y2 + z2) * cos;
		d[1] = x * y * ccos + z * sin;
		d[2] = x * z * ccos - y * sin;
		d[4] = x * y * ccos - z * sin;
		d[5] = y2 + (x2 + z2) * cos;
		d[6] = y * z * ccos + x * sin;
		d[8] = x * z * ccos + y * sin;
		d[9] = y * z * ccos - x * sin;
		d[10] = z2 + (x2 + y2) * cos;
		d[12] = d[13] = d[14] = 0; // This always sets origin to 0?
		d[15] = 1;
		matrix.append(m);
	}

	public inline static function alloclessAppendRotationDegrees(matrix:Matrix3D, radian:Float, axis:Vector3D) {
		return alloclessAppendRotation(matrix, radian * degToRad, axis);
	}

	/**
		Based on Matrix3D's pointAt, but allocationless.

		__Note:__ This makes use of temporary vectors

		https://stackoverflow.com/questions/349050/calculating-a-lookat-matrix
	**/
	public inline static function lookAt(matrix:Matrix3D, pos:Vector3D, ?at:Vector3D, ?up:Vector3D):Matrix3D {
		if(at == null) at = FORWARD;
		if(up == null) up = UP;

		// zaxis = normal(At - Eye)
		final forward = __tempVector;
		forward.copyFrom(at);
		forward.decrementBy(pos);
		forward.normalize();

		// xaxis = normal(cross(Up, zaxis))
		final right = __tempVector2;
		right.copyFrom(up);
		right.crossProductToOutput(forward, right);
		// no normalization to be onpar with flash

		// yaxis = cross(zaxis, xaxis)
		final vup = __tempVector3;
		vup.copyFrom(forward);
		vup.crossProductToOutput(right, vup);

		final a = matrix.rawData.__array;
		a[0] = right.x;
		a[4] = right.y;
		a[8] = right.z;
		a[12] = 0.0;
		a[1] = vup.x;
		a[5] = vup.y;
		a[9] = vup.z;
		a[13] = 0.0;
		a[2] = forward.x;
		a[6] = forward.y;
		a[10] = forward.z;
		a[14] = 0.0;
		a[3] = pos.x;
		a[7] = pos.y;
		a[11] = pos.z;
		a[15] = 1.0;
		return matrix;
	}

	/**
		Extracts the euler angles aka rotation from a transform matrix.

		Warning! This assumes the scale is 1, if the scale is other than 1, the 
		rotation will not be accurate and weird things can happen!
		Make sure to provide a scale vector to fix this if needed.

		__Note:__ XYZ order only
	**/
	// Adapted from https://github.com/mrdoob/three.js/blob/dev/src/math/Euler.js
	public static function eulerFromMatrix(m:Matrix3D, ?output:Vector3D, ?scale:Vector3D) {
		var mt = m.rawData.__array;
		var e = output ?? new Vector3D();

		if(scale == null) {
			e.y = Math.asin(mt[8]);
			if(Math.abs(mt[8]) < 0.9999999) {
				e.x = Math.atan2(-mt[9], mt[10]);
				e.z = Math.atan2(-mt[4], mt[0]);
			}
			else {
				e.x = Math.atan2(mt[6], mt[5]);
				e.z = 0;
			}
			return e;
		}
		
		// With scale applied
		e.y = Math.asin(mt[8] / scale.z);
		if(Math.abs(mt[8] / scale.z) < 0.9999999) {
			e.x = Math.atan2(-mt[9] / scale.z, mt[10] / scale.z);
			e.z = Math.atan2(-mt[4] / scale.y, mt[0] / scale.x);
		}
		else {
			e.x = Math.atan2(mt[6] / scale.y, mt[5] / scale.y);
			e.z = 0;
		}
		return e;
	}

	/**
		Converts a quaternion rotation to euler angles. This operation is not safely reversible.

		__Note:__ This expects the quaternion vector to be normalized.
	**/
	public inline static function eulerFromQuaternion(quat:Vector3D, ?output:Vector3D):Vector3D {
		return eulerFromQuaternionComponent(quat.x, quat.y, quat.z, quat.w, output);
	}

	public static function eulerFromQuaternionComponent(x:Float, y:Float, z:Float, w:Float, ?output:Vector3D):Vector3D {
		var e = output ?? new Vector3D();

		var m0 = 1 - 2 * y * y - 2 * z * z,
			m4 = 2 * x * y - 2 * w * z,
			m5 = 1 - 2 * x * x - 2 * z * z,
			m6 = 2 * y * z + 2 * w * x,
			m8 = 2 * x * z + 2 * w * y,
			m9 = 2 * y * z - 2 * w * x,
			m10 = 1 - 2 * x * x - 2 * y * y;

		e.y = Math.asin(m8);
		if(Math.abs(m8) < 0.9999999) {
			e.x = Math.atan2(-m9, m10);
			e.z = Math.atan2(-m4, m0);
		}
		else {
			e.x = Math.atan2(m6, m5);
			e.z = 0;
		}
		return e;
	}

	public static function quaternionFromMatrix(matrix:Matrix3D, ?output:Vector3D):Vector3D {
		final mat = __tempMatrix;
		mat.copyRawDataFrom(matrix.rawData);

		var quaternion = mat.decompose(cast 2)[1];
		FoxRenderer.allocationsThisFrame += 4;
		if(output == null)
			return quaternion;
		
		output.copyFrom(quaternion);
		output.w = quaternion.w;
		return output;
	}

	public inline static function quaternionFromEuler(rot:Vector3D, ?output:Vector3D):Vector3D {
		return quaternionFromEulerComponent(rot.x, rot.y, rot.z, output);
	}

	/**
		From OpenFL's Matrix3D.recompose(EULER_ANGLES) -> decompose(QUATERNION), allocationless.
	**/
	public static function quaternionFromEulerComponent(x:Float, y:Float, z:Float, ?output:Vector3D):Vector3D {
		if(output == null) {
			output = new Vector3D();
			FoxRenderer.allocationsThisFrame += 1;
		}
		// Euler -> Matrix
		var cx = Math.cos(x);
		var cy = Math.cos(y);
		var cz = Math.cos(z);
		var sx = Math.sin(x);
		var sy = Math.sin(y);
		var sz = Math.sin(z);

		var mr0 = cy * cz;
		var mr1 = cy * sz;
		var mr2 = -sy;
		var mr4 = sx * sy * cz - cx * sz;
		var mr5 = sx * sy * sz + cx * cz;
		var mr6 = sx * cy;
		var mr8 = cx * sy * cz + sx * sz;
		var mr9 = cx * sy * sz - sx * cz;
		var mr10 = cx * cy;

		// Matrix -> Quaternion
		var tr = mr0 + mr5 + mr10;

		if (tr > 0)
		{
			output.w = Math.sqrt(1 + tr) / 2;

			output.x = (mr6 - mr9) / (4 * output.w);
			output.y = (mr8 - mr2) / (4 * output.w);
			output.z = (mr1 - mr4) / (4 * output.w);
		}
		else if ((mr0 > mr5) && (mr0 > mr10))
		{
			output.x = Math.sqrt(1 + mr0 - mr5 - mr10) / 2;

			output.w = (mr6 - mr9) / (4 * output.x);
			output.y = (mr1 + mr4) / (4 * output.x);
			output.z = (mr8 + mr2) / (4 * output.x);
		}
		else if (mr5 > mr10)
		{
			output.y = Math.sqrt(1 + mr5 - mr0 - mr10) / 2;

			output.x = (mr1 + mr4) / (4 * output.y);
			output.w = (mr8 - mr2) / (4 * output.y);
			output.z = (mr6 + mr9) / (4 * output.y);
		}
		else
		{
			output.z = Math.sqrt(1 + mr10 - mr0 - mr5) / 2;

			output.x = (mr8 + mr2) / (4 * output.z);
			output.y = (mr6 + mr9) / (4 * output.z);
			output.w = (mr1 - mr4) / (4 * output.z);
		}
		return output;
	}

	/**
		Extracts the scale from a transform matrix.

		Make sure to apply this first before extracting euler angles too if needed.
	**/
	public static function scaleFromMatrix(m:Matrix3D, ?output:Vector3D) {
		var mr = m.rawData.__array;
		var scale = output ?? new Vector3D();

		scale.x = Math.sqrt(mr[0] * mr[0] + mr[1] * mr[1] + mr[2] * mr[2]);
		scale.y = Math.sqrt(mr[4] * mr[4] + mr[5] * mr[5] + mr[6] * mr[6]);
		scale.z = Math.sqrt(mr[8] * mr[8] + mr[9] * mr[9] + mr[10] * mr[10]);

		if (mr[0] * (mr[5] * mr[10] - mr[6] * mr[9]) - mr[1] * (mr[4] * mr[10] - mr[6] * mr[8]) + mr[2] * (mr[4] * mr[9] - mr[5] * mr[8]) < 0)
		{
			scale.z = -scale.z;
		}
		return scale;
	}

	/**
		Returns the direction of a 1D value (similar to sign, but can be 0)
	**/
	public inline static function direction1D(dir:Float):Int {
		return dir < 0 ? -1 : (dir > 0 ? 1 : 0);
	}

	/**
		GLSL euclidean modulo operation, always unsigned

		From Flixel 6's FlxMath, but here for older versions
	**/
	public static inline function glslMod(a:Float, b:Float):Float
	{
		b = Math.abs(b);
		return a - b * Math.floor(a / b);
	}
	
	public static inline function glslClamp(v:Float, min:Float, max:Float):Float {
		return Math.min(Math.max(v, min), max);
	}

	public static inline function glslClampInt(v:Int, min:Int, max:Int):Int {
		v = v > min ? v : min;
		return v < max ? v : max;
	}

	/**
		Returns the base 2 logarithm of a number
	**/
	public static inline function glslLog2(v:Float):Float {
		return Math.log(v) / LN2;
	}

	public static function directionOf(matrix:Matrix3D):Vector3D {
		FoxRenderer.allocationsThisFrame += 1;
		var a = matrix.rawData.__array;
		var v = new Vector3D(a[8], a[9], a[10]);
		v.normalize();
		return v;
	}

	public static function directionOfToOutput(matrix:Matrix3D, output:Vector3D):Vector3D {
		var a = matrix.rawData.__array;
		output.setTo(a[8], a[9], a[10]);
		output.normalize();
		return output;
	}

	public static function bakeMVP(model:Matrix3D, view:Matrix3D, projection:Matrix3D):Matrix3D {
		FoxRenderer.allocationsThisFrame += 1;
		var mvp = new Matrix3D();
		mvp.append(model);
		mvp.append(view);
		mvp.append(projection);
		return mvp;
	}

	public static function bakeMVPToOutput(model:Matrix3D, view:Matrix3D, projection:Matrix3D, output:Matrix3D):Matrix3D {
		output.copyRawDataFrom(model.rawData);
		output.append(view);
		output.append(projection);
		return output;
	}
}