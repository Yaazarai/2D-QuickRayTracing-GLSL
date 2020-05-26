uniform sampler2D in_WorldMap; // The texture of the game's world/collision map.
uniform vec3 in_Light; // X, Y and Z (radius) of the light that is being ray-traced.
uniform vec2 in_World; // Size of the world/collision texture we're tracing rays against.
uniform float in_RayTexSize; // Size of the texture that the rays are being stored on.
varying vec2 in_Coord; // The UV coordinate of the current pixel.
const float MAXRADIUS = 65535., // Maximum ray-length of 2 bytes, 2^16-1.
	TAU = 6.2831853071795864769252867665590; // TAU or 2 * pi (shortcut for radial.circular math).

void main() {
	// Converts the current pixel's coordinate from UV to XY space.
	vec2 Coord = floor(in_Coord * in_RayTexSize),
		// Takes the pixel's XY position, converts it to a vec2(1D-array index, ray count).
		xyRay = vec2((Coord.y * in_RayTexSize) + Coord.x, TAU * in_Light.z);
	// Takes the index/ray_count and converts it to an angle in range of: 0 to 2pi = 0 to ray_count.
	float Theta = TAU * (xyRay.x / xyRay.y);
	// Gets the lengthdir_xy polar cooridinate around the light's center.
	vec2 Delta = vec2(cos(Theta), -sin(Theta));
	// "Step" gets checks whether the current ray index < ray count, if not the ray is not traced (for-loop breaks).
	float v1 = step(xyRay.x,xyRay.y);
	for(float v = step(xyRay.x,xyRay.y), d = 0.; d < MAXRADIUS * v; d++)
		/*
			"in_Light.z < d" Check if the current ray distance(length) "d" is > light radius (if so, then break).
			"d + in_Light.z * texture2D(...)" If collision in the world map at distance "d" is found, the ray ends
			(add light radius to d to make it greater than the light radius to break out of the for-loop.
		*/
		if (in_Light.z < d + in_Light.z * texture2D(in_WorldMap, (in_Light.xy + (xyRay = Delta * d)) * in_World).a) break;
	// Converts the ray length to polar UV coordinates ray_length / light_radius.
	float rayLength = length(xyRay) / in_Light.z;
	// Takes the length of the current ray and splits it into two bytes and stores it in the texture.
	gl_FragColor = vec4(vec2(floor(rayLength * 255.0) / 255.0, fract(rayLength * 255.0)), 0.0, 1.0);
}
