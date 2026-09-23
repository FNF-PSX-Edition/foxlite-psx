// Samplers
#ifdef FRAGMENT
uniform sampler2D bitmap;	   // Albedo
#ifdef NORMAL_MAP
uniform sampler2D normalMap;   // Normals
#endif
#ifdef EMISSIVE_MAP
uniform sampler2D emissiveMap; // Emissive
#endif
#ifdef ORM_MAP
uniform sampler2D ormMap;      // AO, Roughness, Metallic
#endif
#endif

// For Phong BRDF and PBR
uniform float uRoughness;  	  // = 0.0
uniform float uMetallic;   	  // = 0.0
uniform float uScattering; 	  // = 0.5
uniform vec3 uEmissive;
uniform vec3 uSpecular;

// Index of refraction
//uniform float uIOR;
const float uIOR = 1.5;

// UV suff
uniform vec2 uvScale;
uniform vec2 uvOffset;

// Color and rendering
#ifndef NO_ALPHA_SCISSOR
uniform float alphaScissor;
#endif
uniform vec4 color;
// Fog
uniform float fogStart;		  // Z position from the camera where fog will start
uniform float fogEnd;		  // Z position from the camera where fog will end
uniform vec4 fogColor; 		  // Used when FOG is defined, note: Alpha only works when VERTEX_LIGHTING is disabled

// Rimlight
#if defined(RIMLIGHT)
uniform float rimLightPower;
uniform vec2 rimLightCurve;
#endif