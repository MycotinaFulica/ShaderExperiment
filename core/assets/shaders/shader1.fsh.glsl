
//invert color shader
/*varying vec4 v_color;
varying vec2 v_texCoord0;

uniform sampler2D u_sampler2D;

void main() {
	vec4 color = texture2D(u_sampler2D, v_texCoord0) * v_color;
	color.rgb = 1. - color.rgb;
	gl_FragColor = vec4(vec3(v_texCoord0.s/2 + v_texCoord0.t/2), 1.0);
}*/

//Lesson 4 shader

#define amp 0.02
#define tint_color vec4(0.45, 0.89,0.99, 1)

varying vec4 v_color;
varying vec2 v_texCoord0;

uniform sampler2D u_texture;
uniform sampler2D u_texture1;
uniform sampler2D u_mask;

uniform float time;
uniform vec2 u_resolution;

vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x){
    return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec2 v){
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0\n" +
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)\n" +
    			       -0.577350269189626,  // -1.0 + 2.0 * C.x\n" +
    			        0.024390243902439);

    //first corner
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);

    //other corners
    vec2 i1;
    //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
    //i1.y = 1.0 - i1.x;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    // x0 = x0 - 0.0 + 0.0 * C.xx ;
    // x1 = x0 - i1 + 1.0 * C.xx ;
    // x2 = x0 - 1.0 + 2.0 * C.xx ;
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 )) + i.x + vec3(0.0, i1.x, 1.0 ));
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    // Gradients: 41 points uniformly over a line, mapped onto a diamond
    // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    // Normalise gradients implicitly by scaling
    // Approximation of: m *= inversesqrt( a0*a0 + h*h )
     m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
     // Compute final noise value at
     vec3 g;
     g.x  = a0.x  * x0.x  + h.x  * x0.y;
     g.yz = a0.yz * x12.xz + h.yz * x12.yw;
     return 130.0 * dot(m, g);
}

float mod1(float x)
{
    return x - 0.5*floor(x/0.5);
}

float mod2(float x)
{
    return x - 0.75*floor(x/0.75);
}

float mod3(float x)
{
    return x - 0.65*floor(x/0.65);
}

float mod4(float x)
{
    return x - 0.25*floor(x/0.25);
}

void main(){
    float turbulance = 2*sin(time/2);
    float timeMod = time - 10.5*floor(time/10.5);
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 p = uv + (vec2(.5)-texture(u_texture, uv*0.3+vec2(sin(2.25*time*0.05)/2, sin(2.25*time*0.025)/2)).xy)*amp +
                  (vec2(.5)-texture(u_texture, uv*0.3-vec2(-sin(2.5*time*0.005)/2, sin(2.5*time*0.0125)/2)).xy)*amp;

    //sample color of the first texture
    vec4 texColor0 = texture2D(u_texture, v_texCoord0);

    //sample color of the second texture
    vec4 texColor1 = texture2D(u_texture1, v_texCoord0);

    //pertube texcoord by x and y\n"
    vec2 distort = 0.1 * vec2(snoise(v_texCoord0 + vec2(0.0, time/3.0)) + snoise(v_texCoord0 + vec2(time/3.0, 0.0)));

    //get the alpha channel of the mask
    float mask = texture2D(u_mask, v_texCoord0 + distort).a;

    //do interpolation based on the mask
    gl_FragColor =  texture(u_texture, p)*tint_color;
}