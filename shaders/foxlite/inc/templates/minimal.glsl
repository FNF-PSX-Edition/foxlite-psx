#include "foxlite/inc/foxlite.glsl"
#include "foxlite/inc/material.glsl" // for color
#ifdef VERTEX
#include "foxlite/inc/mesh.glsl"
#include "foxlite/inc/armature.glsl"
#endif

//////////////////////////// VERTEX SHADER ////////////////////////////
#ifdef VERTEX
#undef mainVert
void mainVert_minimal(void)
{
	foxlite_TexCoordv = foxlite_TexCoord * uvScale + uvOffset;
	foxlite_Colorv = foxlite_Color * color;

	mat4 worldTransform = model;

	// Instancing
	if(uInstanced) {
		foxlite_Colorv *= foxlite_InstanceColor;
		worldTransform = worldTransform * foxlite_InstanceTransform;
	}

	mat4 fmodelView = view * worldTransform;
	
	// Skinning
	if(uSkinned) fmodelView = fmodelView * skin();

	gl_Position = projection * fmodelView * vec4(foxlite_Position.xyz, 1.0);
}
#define mainVert mainVert_minimal
#endif

/////////////////////////////////////////////////////////////////////////

//////////////////////////// FRAGMENT SHADER ////////////////////////////

#ifdef FRAGMENT
#undef mainFrag
void mainFrag_minimal() {
	#ifndef SOLID
	vec4 albedo = texture2D(bitmap, foxlite_TexCoordv) * foxlite_Colorv;
	#else
	vec4 albedo = foxlite_Colorv;
	#endif
	
	gl_FragData[0] = albedo;
}
#define mainFrag mainFrag_minimal
#endif
/////////////////////////////////////////////////////////////////////////