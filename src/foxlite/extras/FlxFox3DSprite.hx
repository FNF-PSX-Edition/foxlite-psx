package foxlite.extras;

import foxlite.math.FoxMathUtil;
import openfl.geom.Matrix3D;
import flixel.FlxSprite;

/**
	This class copies its transform to **foxlite's flixel_sprite** shader

	Use it when you need flixel sprites rendered in flixel to have a 3D perspective

	```haxe
	var sprite3D = new FlxFox3DSprite(yourSprite, new YourShader("foxlite/flixel_sprite"));
	
	// Once added, the sprite will be positioned and transformed at `sprite3D`
	offlineScene.add(transformable);
	```
**/
class FlxFox3DSprite extends FoxObject {

	public var sprite:FlxSprite;

	/**
		The Projection-View-Model matrix, this bakes all transforms to be used in a single uniform
	**/
	public var MVP:Matrix3D = new Matrix3D();
	
	/**
		@param target the target sprite to be used
		@param shader the flixel shader to recieve the transformations
	**/
	public function new(target:FlxSprite, shader:flixel.graphics.tile.FlxGraphicsShader) {
		super();
		sprite = target;
		sprite.shader = shader;
	}

	public override function draw(camera:FoxCamera) {
		super.draw(camera);
		if(sprite?.shader == null) return;
		FoxMathUtil.bakeMVPToOutput(transform, camera.viewMatrix, camera.projectionMatrix, MVP);
		
		var data:openfl.display.ShaderData = sprite.shader.data;
		if(data.foxlite_MVP_row0 != null) {
			var a = MVP.rawData.__array;
			data.foxlite_MVP_row0.value = [a[0],a[1],a[2],a[3]];
			data.foxlite_MVP_row1.value = [a[4],a[5],a[6],a[7]];
			data.foxlite_MVP_row2.value = [a[8],a[9],a[10],a[11]];
			data.foxlite_MVP_row3.value = [a[12],a[13],a[14],a[15]];
		}

		var pos = sprite.getScreenPosition(null, sprite.camera);
		if(data.flixel_Screen != null) data.flixel_Screen.value = [pos.x, pos.y, 1 / sprite.camera.width, -1 / sprite.camera.height];
	}

	public override function destroy() {
		MVP = null;
		sprite = null;
		super.destroy();
	}
}