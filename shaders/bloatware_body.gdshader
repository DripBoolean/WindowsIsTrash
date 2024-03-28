shader_type spatial;

uniform sampler2D noise;
uniform sampler2D normal_map;
uniform float height_multiplier: hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float noise_sample_size: hint_range(0.0, 0.5, 0.01) = 0.1;
uniform float time_speed: hint_range(0.0, 0.5, 0.01) = 0.1;
uniform float is_alpha: hint_range(0.0, 1.0, 0.1) = 1.0;

uniform vec4 color: source_color;

varying float height;

float fresnel(vec3 normal, mat4 camera_matrix) {
	vec3 view_direction_world = (camera_matrix * vec4(0.0, 0.0, 1.0, 0.0)).xyz;
	vec3 normal_world = (camera_matrix * vec4(normal, 0.0)).xyz;
	
	float d = dot(view_direction_world, normal_world);
	d = abs(d);
	d = clamp(d, 0.0, 1.0);
	
	return 1.0 - d;
}

void vertex() {
	// Called for every vertex the material is visible on.
	height = texture(noise, VERTEX.xz * noise_sample_size + vec2(TIME) * time_speed).r;
	VERTEX += NORMAL * height * height_multiplier;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ROUGHNESS = mix(0.05, 0.1, 1.0 - height);
	SPECULAR = height;
	vec4 normal_m = texture(normal_map, UV);
	//ALPHA = fresnel(NORMAL, VIEW_MATRIX);
	ALBEDO = color.rgb * normal_m.rgb + fresnel(NORMAL, VIEW_MATRIX) * 0.2;
	ALBEDO *= normal_m.rgb;
	ALBEDO.b *= sin(TIME * UV.y) + fresnel(NORMAL, VIEW_MATRIX);
	ALPHA = clamp(fresnel(NORMAL, VIEW_MATRIX), is_alpha, 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
