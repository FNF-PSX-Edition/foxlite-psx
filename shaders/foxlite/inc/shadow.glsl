#ifndef SHADOW_GLSL
#define SHADOW_GLSL

#ifdef VERTEX
uniform sampler2D shadowCasterData;
uniform float shadowCasterDataSize;
#endif

#if MAX_DIRECTIONAL_LIGHTS > 0
	uniform sampler2DShadow shadowtex0; // Directional light shadow atlas
	uniform vec2 shadowtex0size;
	varying vec4 directionalShadowLightSpace[MAX_DIRECTIONAL_LIGHTS];
#endif
#if MAX_POINT_LIGHTS > 0
	varying vec4 pointShadowLightSpace[1];
#endif
#if MAX_SPOT_LIGHTS > 0
	uniform sampler2DShadow shadowtex2; // Spot light shadow atlas
	uniform vec2 shadowtex2size;
	varying vec4 spotShadowLightSpace[MAX_SPOT_LIGHTS];
#endif
#if MAX_AREA_LIGHTS > 0
	varying vec4 areaShadowLightSpace[1];
#endif

// Shadow data
#define ESHADOW_CASTER 0
#define ESHADOW_BIAS 1
#define ESHADOW_BLUR 2
#define ESHADOW_NORMAL_BIAS 3

#ifdef FRAGMENT
#include "foxlite/inc/shadow_filters.glsl"
#endif

// For shadow clipping
#define outsideBounds(v) any(bvec2(any(lessThan(v, vec2(0))), any(greaterThan(v, vec2(1)))))

vec3 normalBias(vec3 pos, vec3 normal, vec3 lightDir, float bias) {
	float NdotL = clamp(dot(normal, lightDir), 0.0, 1.0);
	float sinTheta = sqrt(1.0 - NdotL * NdotL);
	return pos + normal * (bias * sinTheta);
}

#ifdef VERTEX
void setupShadows(vec4 worldPosition, vec3 normal) {
	normal = viewToWorld(normal);

	#if MAX_DIRECTIONAL_LIGHTS > 0
	for(int i = 0; i < MAX_DIRECTIONAL_LIGHTS; ++i) {
		if(i >= lightCount[LIGHT_DIRECTIONAL]) break;
		DirLight L = directionalLights[i];
		if(L.shadowData[ESHADOW_CASTER] >= 0.0) {
			mat4 viewProjection = fox_textureBufferMat4(shadowCasterData, int(L.shadowData[ESHADOW_CASTER]), shadowCasterDataSize);
			// normal bias
			vec3 worldPosOffset = normalBias(worldPosition.xyz, normal, L.direction.xyz, L.shadowData[ESHADOW_NORMAL_BIAS]);

			directionalShadowLightSpace[i] = viewProjection * vec4(worldPosOffset, 1);
			directionalShadowLightSpace[i].xyz = directionalShadowLightSpace[i].xyz * 0.5 + 0.5;
			directionalShadowLightSpace[i].z -= L.shadowData[ESHADOW_BIAS];
		}
	}
	#endif

	#if MAX_POINT_LIGHTS > 0
	for(int i = 0; i < 1; ++i) {
		if(i >= lightCount[LIGHT_POINT]) break;
		PointLight L = pointLights[i];
		if(L.shadowData[ESHADOW_CASTER] >= 0.0) {
			mat4 viewProjection = fox_textureBufferMat4(shadowCasterData, int(L.shadowData[ESHADOW_CASTER]), shadowCasterDataSize);

			pointShadowLightSpace[i] = viewProjection * worldPosition;
		}
	}
	#endif

	#if MAX_SPOT_LIGHTS > 0
	for(int i = 0; i < MAX_SPOT_LIGHTS; ++i) {
		if(i >= lightCount[LIGHT_SPOT]) break;
		SpotLight L = spotLights[i];
		if(L.shadowData[ESHADOW_CASTER] >= 0.0) {
			mat4 viewProjection = fox_textureBufferMat4(shadowCasterData, int(L.shadowData[ESHADOW_CASTER]), shadowCasterDataSize);
			// normal bias
			vec3 worldPosOffset = normalBias(worldPosition.xyz, normal, L.direction.xyz, L.shadowData[ESHADOW_NORMAL_BIAS]);

			spotShadowLightSpace[i] = viewProjection * vec4(worldPosOffset, 1);
		}
	}
	#endif

	#if MAX_AREA_LIGHTS > 0
	for(int i = 0; i < 1; ++i) {
		if(i >= lightCount[LIGHT_AREA]) break;
		AreaLight L = areaLights[i];
		if(L.shadowData[ESHADOW_CASTER] >= 0.0) {
			mat4 viewProjection = fox_textureBufferMat4(shadowCasterData, int(L.shadowData[ESHADOW_CASTER]), shadowCasterDataSize);
			areaShadowLightSpace[i] = viewProjection * worldPosition;
		}
	}
	#endif

}
#endif

#ifdef FRAGMENT
float shadowDirectional(in vec4 projCoords, const vec4 rect, in float blur) {
	//vec3 projCoords = S.xyz;
	float shadow = 1.0;
	#if MAX_DIRECTIONAL_LIGHTS > 0
	if(!outsideBounds(projCoords.xy)) {
		vec2 coord = mix(rect.xy, rect.zw, projCoords.xy); // Atlas rect
		shadow = getShadowFilter(shadowtex0, vec3(coord, projCoords.z), shadowtex0size*blur);
	}
	#endif
	return shadow;
}

float shadowSpot(in vec4 S, const vec4 rect, in float bias, in float blur) {
	vec3 projCoords = S.xyz / S.w;
	projCoords = projCoords * 0.5 + 0.5;
	projCoords.z -= bias;

	float shadow = 1.0;
	#if MAX_SPOT_LIGHTS > 0
	if(!outsideBounds(projCoords.xy)) {
		vec2 coord = mix(rect.xy, rect.zw, projCoords.xy); // Atlas rect
		shadow = getShadowFilter(shadowtex2, vec3(coord, projCoords.z), shadowtex2size*blur);
	}
	#endif
	return shadow;
}

float shadowPointCubemap(in vec4 S) {
	return 1.0;
}

float shadowArea(in vec4 S) {
	return 1.0;
}
#endif

#endif
