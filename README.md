# 2D-QuickRayTracing-GLSL
Quick Ray-Tracing (QRT) using GLSL ES shaders in two passes, one pass to trace rays, another to build the lights.

See the GameMaker forum link below for tutorial/explanation: https://forum.yoyogames.com/index.php?threads/quick-ray-traced-qrt-lighting-tutorial.60842/


## Pass One: Ray-Tracer
In the first pass we setup a texture to render all of the rays we trace onto a grid of pixels. The pixel's 2D coordinate position is converted to a 1D index to represent the index of the ray around the light: `index / total_rays`. This ratio can then be multiplied either by `360 degrees` or `2 * PI radians` to get the angle of the ray. We only trace rays with an index lower than the total number of rays we're tracing. The total number of rays is calculated efficiently as `2 * PI * R` or the circumferance of the circle of the light at a specified radius. Once a ray is traced, we get the length of the ray and store that length is the pixel's FRAG color: `gl_FragColor`.

The left half of the GIF shows where in the texture the rays are being traced from. The right-half shows how they're traced.
![ray-tracer](https://i.imgur.com/wax9ehy.gif)

## Pass Two: Light Sampler
The second pass is simple, for all pixels within the light's radius, get the angle of the pixel to the light center, convert that angle to a 1D index, then finally convert that to a 2D position to look up the ray in the ray-traced texture. If the distance from the light to the pixel is shorter than the ray, then the pixel is lit up.

## Example:
Here you can see an example texture output of the ray-tracer. The texture can be seen as split into 4 sections: top (0-90 deg), middle-top (91-180 deg), middle-bottom (181-270 deg), bottom (271-360 deg).

![](https://i.imgur.com/YmcUXdx.png)

You can tell by the reference output:
![](https://i.imgur.com/gYIS12D.png)

See? The color of the ray-traced pixels are dark (0 length) or red (radius length). So the ray-length is represented by the pixel color.

### End Result:
![sampler](https://i.imgur.com/dcEACfu.gif)

### Changing Light Sizes
GLSL/GLSL ES does not allow you to have dynamic loop sizes, so the max radius size must be set within the shader itself as constant. Which means we need to re-define the shader constant values to accomodate differnet light radius'.

The ray-tracer texture size follows this formula: `length = pow(2.,ceil(log2(sqrt(2.*PI*MAXRADI_SIZE))))`. The `RAYTEXT_SIZE` is the nearest higher power of 2, square-root of the circfumerance of the light. E.g. if the radius is 56 then you'll get `square = sqrt(2 * PI * R) = 18` then the nearest higher power of 2 of 18 is 32.

The light-sampler texture size follows this formula: `length = pow(2.,ceil(log2(MAXRADI_SIZE)))*2.;`. The `TEXTURE_SIZE` is 2x the nearest higher power of 2 of the light radius, e.g. `radius = 56` then the size is `2 * 64`.

When you change the `MAXRADI_SIZE` you need to also change the `RAYTEXT_SIZE` and `TEXTURE_SIZE` in both shaders.
