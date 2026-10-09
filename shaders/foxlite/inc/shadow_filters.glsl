
// For any custom implementations, use along SHADOW_FILTER_CUSTOM
float sampleShadowCustom(sampler2DShadow tex, vec3 coord, vec2 texelSize);

float sampleShadowPoisson5(sampler2DShadow tex, vec3 coord, vec2 S) {
	float pDepth = 0.0;
	float a = interleavedGradientNoise(ScreenCoord) * 6.28;
	vec2 sc = vec2(sin(a),cos(a));
	vec4 B = vec4(sc.y, sc.x, -sc.x, sc.y);

	// Unrolled for OpenGL ES 2
	const float NUM_TAPS = 5.0;
	vec2 ofs;
	vec3 texcoord = coord;
	ofs = vec2(-0.8350818852979401, -0.4826388224290488); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2(0.24593728246082208, 0.9588613067368342); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2(0.7796384216727746, -0.6037360528260651); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2(-0.6437966602266678, 0.692457694761556); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2(0.45504401297974184, -0.3128321923487644); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	return pDepth / NUM_TAPS;
}

float sampleShadowPoisson18(sampler2DShadow tex, vec3 coord, vec2 S) {
	float pDepth = 0.0;
	float a = interleavedGradientNoise(ScreenCoord) * 6.28;
	vec2 sc = vec2(sin(a),cos(a));
	vec4 B = vec4(sc.y, sc.x, -sc.x, sc.y);

	// Unrolled for OpenGL ES 2
	const float NUM_TAPS = 18.0;
	vec2 ofs;
	vec3 texcoord = coord;
	ofs = vec2(-0.220147, 0.976896); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2(-0.735514, 0.693436); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2(-0.200476, 0.310353); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2( 0.180822, 0.454146); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2( 0.292754, 0.937414); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2( 0.564255, 0.207879); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2( 0.178031, 0.024583); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2( 0.613912,-0.205936); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2(-0.385540,-0.070092); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2( 0.962838, 0.378319); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2(-0.886362, 0.032122); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2(-0.466531,-0.741458); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2( 0.006773,-0.574796); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2(-0.739828,-0.410584); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2( 0.590785,-0.697557); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2(-0.081436,-0.963262); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2( 1.000000,-0.100160); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;
	ofs = vec2( 0.622430, 0.680868); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord.xy = coord.xy + ofs;
	pDepth += shadow2D(tex, texcoord).r;

	return pDepth / NUM_TAPS;
}

float getShadowFilter(sampler2DShadow tex, vec3 coord, vec2 texelSize) {
	#if defined(SHADOW_FILTER_NONE)
	return shadow2D(tex, coord).r;
	#elif defined(SHADOW_FILTER_CUSTOM)
	return sampleShadowCustom(tex, coord, texelSize);
	#elif defined(SHADOW_FILTER_LQ)
	return sampleShadowPoisson5(tex, coord, texelSize);
	#else
	return sampleShadowPoisson18(tex, coord, texelSize);
	#endif
}