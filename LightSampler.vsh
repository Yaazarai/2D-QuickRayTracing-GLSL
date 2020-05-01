uniform sampler2D in_WorldMap, in_LightMap;
uniform vec3 in_Light, in_Color;
uniform vec2 in_World, in_LightCenter, in_TexCenter;
uniform float in_RayTexSize, in_LightTexSize;
varying vec2 in_Coord;
const float TAU = 6.2831853071795864769252867665590;

void main() {
	vec2 Coord = in_Coord * in_LightTexSize,
		Delta = Coord - in_TexCenter;
	float RayCount = TAU * in_Light.z,
		RayIndex = floor((RayCount * fract(atan(-Delta.y, Delta.x)/TAU)) + 0.5);
	vec2 RayPos = vec2(mod(RayIndex, in_RayTexSize), RayIndex / in_RayTexSize) * (1./in_RayTexSize),
		TexRay = texture2D(in_LightMap, RayPos).rg;
	float Distance = distance(Coord, in_TexCenter),
		RayLength = clamp(TexRay.r + (TexRay.g / 255.0), 0.0, 1.0) * in_Light.z,
		RayVisible = sign(RayLength - Distance) * (1. - texture2D(in_WorldMap, (in_Light.xy + Delta) * in_World).a),
		ToneMap = 1. - (Distance/in_Light.z);
    gl_FragColor = vec4(in_Color * ToneMap, RayVisible);
}
