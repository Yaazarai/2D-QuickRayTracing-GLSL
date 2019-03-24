uniform sampler2D in_WorldMap;
uniform vec2 in_World;
uniform vec3 in_Light;
varying vec2 in_Coord;

#define MAXRADI_SIZE 64.
#define PI 3.1415926535897932384626433832795

const float RAYTEXT_SIZE = 32.; //pow(2.,ceil(log2(sqrt(2.*PI*MAXRADI_SIZE))));
const vec3 in_TexData = vec3(RAYTEXT_SIZE, RAYTEXT_SIZE * 0.5, 1./RAYTEXT_SIZE);
const vec2 in_TexCenter = vec2((RAYTEXT_SIZE * 0.5) + 0.5);
const float PI2 = 2. * PI;

void main() {
	vec2 Coord = floor(in_Coord * in_TexData.x),
		RayMap = vec2((Coord.y * in_TexData.x) + Coord.x, (PI2 * in_Light.z));
	float Result = 0.;
	
	if (RayMap.x <= RayMap.y) {
		float Theta = (PI2 * (RayMap.x / RayMap.y));
		vec2 Step = vec2(cos(Theta), -sin(Theta)), xyRay = vec2(0.);
		
		for(float rad = 0., d = 0.; d < MAXRADI_SIZE; d++)
			if (rad < in_Light.z) {
				xyRay = floor((Step * d) + 0.5);
				rad = d + (in_Light.z * abs(texture2D(in_WorldMap, (in_Light.xy + xyRay) * in_World).a));
			}
		
		Result = length(xyRay) / in_Light.z;
	}
	
	gl_FragColor = vec4(Result, 0., 0., 1.);
}
