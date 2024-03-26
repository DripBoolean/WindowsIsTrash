shader_type spatial;

render_mode blend_mix;

#define C(x) sin(x) * 0.5 + 0.5

uniform vec2 resolution = vec2(600.0, 400.0);
uniform int octaves: hint_range(1, 10, 1) = 5;
uniform float speed: hint_range(0.1, 4.0, 0.1) = 1.0;
uniform float frequency: hint_range(0.1, 10.0, 0.1) = 1.0;
uniform float amplitude: hint_range(0.1, 10.0, 0.1) = 1.0;
uniform float time_shift: hint_range(0.1, 10.0, 0.1) = 1.0;
uniform float zoom: hint_range(1.0, 20.0, 0.1) = 5.0;

//PLASTIC LOOK
uniform float radiance: hint_range(0.1, 4.0, 0.1) = 0.5;
uniform float sharpness: hint_range(0.1, 10.0, 0.1) = 2.0;
uniform float gloss: hint_range(0.1, 2.0, 0.01) = 0.75;


vec2 warp(vec2 uv, float time) {
	float f = frequency;
	float a = amplitude;
	float t = time_shift;
	for (int s = 0; s < octaves; s++) {
		uv += vec2(sin(uv.y * f + time * t), cos(uv.x * f + time * t)) / a;
		f *= 1.9;
		t *= 0.9;
		a *= 2.0;
	}
	return uv;
}

vec4 gloss_effect(vec4 color) {
	float shine = pow(abs(normalize(vec3(length(dFdx(color)), length(dFdy(color)), radiance / resolution.y)).z), sharpness) + gloss;
	return color * shine;
}

vec2 bubble(vec2 vert, float time) {
	float amp= 2.0;
	float freq = 3.0;
	for (int s = 0; s < 3; s++) {
		vert += vec2(sin(vert.y * freq + time), cos(vert.x * freq + time)) / amp;
		freq *= 2.;
		amp *= 2.;
	}
	return vert;
}

void vertex() {
	float time = TIME * speed;
	vec3 vertex = VERTEX;
	vertex.xz = bubble(vertex.xz, time) / 2.0;
	VERTEX = vertex;
}

void fragment() {
	// Called for every pixel the material is visible on.
	float time = TIME * speed;
	vec2 uv = UV - 1.25;
	uv.y = UV.y - 0.2;
	//uv.x *= resolution.x / resolution.y;
	uv *= zoom;
	uv = warp(uv, time);
	float r = C(uv.x + time);
	float g = C(uv.y - time);
	float b = C(uv.x * uv.y + C(time * 0.5)) +0.2;
	vec4 color = gloss_effect(vec4(r, g, b, 1.0));
	ALBEDO = color.rgb;
}