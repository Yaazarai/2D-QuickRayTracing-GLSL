uniform sampler2D in_WorldMap, in_RayMap;
uniform vec3 in_Light, in_ColorS, in_ColorD;
uniform vec2 in_WorldTexSize, in_LightCenter;
uniform float in_RayTexSize, in_LightTexSize;
varying vec2 in_Coord;
const float TAU = 6.2831853071795864769252867665590;
const float PI = TAU/2.;

// Custom tone map function, adjust as you please, keep in range 0 to 1.
float ToneMapFunc(float d, float m) {
	return clamp(1. - (d/m), 0., 1.);
}

void main() {
	// Gets the current pixel's texture XY coordinate from it's texture UV coordinate.
	vec2 Coord = in_Coord * in_LightTexSize,
		// Gets the lengthdir_xy of the current pixel in reference to the light position.
		Delta = Coord - in_LightCenter;
	// Gets the ray count as equal to the light's circumference.
	float RayCount = TAU * in_Light.z,
		// Gets the index of the closest ray pointing towards this pixel within the ray texture.
		RayIndex = floor((RayCount * fract(atan(-Delta.y, Delta.x)/TAU)) + 0.5);
	// Gets the position of the closest ray pointing towards this pixel within the ray texture.
	vec2 RayPos = vec2(mod(RayIndex, in_RayTexSize), RayIndex / in_RayTexSize) * (1./in_RayTexSize),
		// Gets the closest ray associated with this pixel.
		TexRay = texture2D(in_RayMap, RayPos).rg;
	// Gets the distance from the current pixel to the light center.
	float Distance = distance(Coord, in_LightCenter),
		// Reads out the length fo the ray itself.
		RayLength = clamp(TexRay.r + (TexRay.g / 255.0), 0.0, 1.0) * in_Light.z,
		// Returns a bool whether or not this pixel is within the ray.
		RayVisible = sign(RayLength - Distance) * (1. - texture2D(in_WorldMap, (in_Light.xy + Delta) * in_WorldTexSize).a),
		// Gets the gradient/tone map based on distance from the pixel to the light.
		ToneMap = ToneMapFunc(Distance, in_Light.z);
	
	// Draw the final pixel output with the source and destination color lerp'd together, then apply the gradient/tonemap.
	gl_FragColor = vec4(mix(in_ColorD, in_ColorS, vec3(ToneMap)) * RayVisible * ToneMap, ToneMap * RayVisible);
}
