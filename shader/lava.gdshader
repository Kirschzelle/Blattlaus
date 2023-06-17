shader_type canvas_item;

uniform sampler2D noise: repeat_enable;
uniform vec2 scroll = vec2(0.0005, 0.0005);
uniform vec2 scroll2 = vec2(-0.0005, -0.0004);
uniform vec2 scroll3 = vec2(-0.0002, 0.0001);
uniform vec2 scroll4 = vec2(0.0005, -0.0003);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float distortion_strength : hint_range(-1,1) = 0.2;

void fragment() {
	vec4 noise_col = texture(noise, UV + scroll * TIME * 0.3)*texture(noise, UV + scroll2 * TIME * 0.3)*texture(noise, UV + scroll3 * TIME * 0.3)*texture(noise, UV + scroll4 * TIME * 0.3);
	COLOR = textureLod(screen_texture, UV * noise_col.rr * 0.9 + UV * 0.1, 0);
}
