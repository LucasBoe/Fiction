shader_type spatial;
render_mode unshaded, cull_back, blend_mix, depth_prepass_alpha;

// noise texture
uniform sampler2D noise_texture;

// fog settings
uniform float density = 0.25;
uniform vec2 speed = vec2(0.02, 0.01);
uniform vec4 fog_color = vec4(0.0, 0.0, 0.0, 0.8);

// UV circle settings (center is 0.5, 0.5)
uniform float clear_radius = 0.25;   // in UV space (0.0 - 0.5)
uniform float edge_softness = 0.05;  // smooth border
uniform vec2 tiling = vec2(1.0,1.0);

void fragment() {

	// Animate noise
	vec2 uv = UV + speed * TIME;

	float noise = texture(noise_texture, uv * tiling).r;
	float fog = noise * 2.0 - 1.0;

	float base_alpha = clamp(fog * density, 0.0, 1.0);

	// Distance from UV center
	float dist = distance(UV, vec2(0.5, 0.5));

	// Circle mask (0 = clear, 1 = fog)
	float circle_mask = smoothstep(
		clear_radius,
		clear_radius + edge_softness,
		dist
	);

	float final_alpha = base_alpha * circle_mask;

	ALBEDO = fog_color.rgb;
	ALPHA = final_alpha;
}
