
attribute vec4 foxlite_Position;
attribute vec2 foxlite_TexCoord;
attribute vec3 foxlite_Normal;
attribute vec4 foxlite_Tangent; // Precomputed tangent from normal, used for TBN matrix for advanced light calculations.

#ifdef VERTEX_COLORS
attribute vec4 foxlite_Color;
#else
#define foxlite_Color vec4(1)
#endif

// For instancing
attribute mat4 foxlite_InstanceData; // 3x4 matrix and user data / color

uniform bool uInstanced;

//#define foxlite_InstanceTransform mat4(vec3(foxlite_InstanceData0), 0, vec3(foxlite_InstanceData1), 0, vec3(foxlite_InstanceData2), 0, foxlite_InstanceData0.w, foxlite_InstanceData1.w, foxlite_InstanceData2.w, 1)
#define foxlite_InstanceTransform mat4(vec3(foxlite_InstanceData[0]), 0, vec3(foxlite_InstanceData[1]), 0, vec3(foxlite_InstanceData[2]), 0, foxlite_InstanceData[0].w, foxlite_InstanceData[1].w, foxlite_InstanceData[2].w, 1)
#define foxlite_InstanceColor foxlite_InstanceData[3]