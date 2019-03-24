uniform sampler2D in_WorldMap, in_LightMap;
uniform vec3 in_Light, in_Color;
uniform vec2 in_World;
varying vec2 in_Coord;

#define MAXRADI_SIZE 64.
#define PI 3.1415926535897932384626433832795

const float RAYTEXT_SIZE = 32.;  //pow(2.,ceil(log2(sqrt(2.*PI*MAXRADI_SIZE))));
const float TEXTURE_SIZE = 128.; //pow(2.,ceil(log2(MAXRADI_SIZE)))*2.;

const vec3 in_TexData = vec3(TEXTURE_SIZE, TEXTURE_SIZE * 0.5, 1./TEXTURE_SIZE);
const vec2 in_TexCenter = vec2((TEXTURE_SIZE * 0.5) + 0.5);
const float PI2 = 2. * PI;

float getRayFromIndex(float index) {
	vec2 RayPos = vec2(mod(index, RAYTEXT_SIZE), index / RAYTEXT_SIZE) * (1./RAYTEXT_SIZE);
	return texture2D(in_LightMap, RayPos).x * in_Light.z;
}

float getNearIndex(float index) {
	return 1. + (-2. * (1. - floor(fract(index) + 0.5)));
}

void main() {
	vec2 Coord = in_Coord * in_TexData.x;
	float Result = 0., Distance = distance(Coord, in_TexCenter);
	vec4 Color = vec4(0.);
	
	if (Distance < in_Light.z-1.) {
		vec2 Delta = Coord - in_TexCenter;
		float RayCount = (PI2 * in_Light.z);
		float RayIndex = RayCount * fract(atan(-Delta.y, Delta.x)/PI2);
		float RayIndexNear = RayIndex + getNearIndex(RayIndex);
		float xyRay2, xyRay = getRayFromIndex(RayIndex);
		Result = sign(xyRay - Distance) * (1. - (Distance/in_Light.z));
		
		if (Result <= 0.)
			if ((RayIndexNear-RayCount) * RayIndexNear <= 0.) {
				xyRay2 = getRayFromIndex(RayIndexNear);
				Result = sign(xyRay2 - Distance) * (1. - (Distance/in_Light.z));
			}
		
		Result *= (1. - texture2D(in_WorldMap, (in_Light.xy + Delta) * in_World).a);
		Color = vec4(in_Color, 1.) * Result;
	}
	
    gl_FragColor = Color;
}
