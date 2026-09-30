// Default composite vertex shader, include this if you only need fragment
#include "foxlite/inc/foxlite.glsl"
#include "foxlite/inc/material.glsl"

void main(void) {
	gl_FragColor = texture2D(bitmap, foxlite_TexCoordv);
}