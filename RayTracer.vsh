uniform sampler2D in_WorldMap;
uniform vec3 in_Light;
uniform vec2 in_World;
uniform float in_RayTexSize;
varying vec2 in_Coord;
const float MAXRADIUS = 65535., TAU = 6.2831853071795864769252867665590;

void main() {
	vec2 Coord = floor(in_Coord * in_RayTexSize),
		xyRay = vec2((Coord.y * in_RayTexSize) + Coord.x, TAU * in_Light.z);
	float Theta = TAU * (xyRay.x / xyRay.y);
	vec2 Delta = vec2(cos(Theta), -sin(Theta));
	
	float Validated = step(xyRay.x,xyRay.y);
	for(float d = 0.; d < MAXRADIUS * Validated; d++) {
		if (in_Light.z < d + in_Light.z * texture2D(in_WorldMap, (in_Light.xy + xyRay) * in_World).a) break;
		xyRay = floor(Delta * d + 0.5);
	}
	
	float rayLength = length(xyRay) / in_Light.z;
	gl_FragColor = vec4(vec2(floor(rayLength * 255.0) / 255.0, fract(rayLength * 255.0)), 0.0, 1.0);
}
