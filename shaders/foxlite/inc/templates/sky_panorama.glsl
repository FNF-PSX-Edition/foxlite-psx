#include "foxlite/inc/foxlite.glsl" // For texture coordinates
#ifdef VERTEX
#include "foxlite/inc/mesh.glsl"     // For mesh
#else
#include "foxlite/inc/material.glsl"
#endif
#include "foxlite/inc/sky.glsl"      // For worldDirection


//////////////////////////// VERTEX SHADER ////////////////////////////
#ifdef VERTEX
#undef mainVert
void mainVert_sky_panorama(void) {
	// We calculate the world direction, this is where the pixel is in the world
	// That position gets affected by camera rotation and projection
	// UV is in screen space, so we have to walk all the way back to world coords
	// check utils.inc for the functions for this
	vec3 ndc = screenToNDC(foxlite_TexCoord);
	vec4 view = ndcToView(ndc);
	
	worldDirection = viewToWorld(view);

    gl_Position = vec4(foxlite_Position.x, -foxlite_Position.y, -1.0, 1.0);
}
#define mainVert mainVert_sky_panorama
#endif

/////////////////////////////////////////////////////////////////////////

//////////////////////////// FRAGMENT SHADER ////////////////////////////

#ifdef FRAGMENT
#undef mainFrag
void mainFrag_sky_panorama(void) {
	gl_FragColor = panoramaSky(skyTexture, normalize(worldDirection));
}
#define mainFrag mainFrag_sky_panorama
#endif
/////////////////////////////////////////////////////////////////////////