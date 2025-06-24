shader_type canvas_item;

uniform sampler2D pixel_texture : hint_default_white;
uniform vec2 screen_size = vec2(480, 270);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float overlay_intensity = 0.7;

void fragment() {
	//vec2 offset = vec2(2.0, 2.0) * SCREEN_PIXEL_SIZE;
	vec2 crt_uv = (UV) * screen_size;
	crt_uv -= floor(crt_uv);
	vec4 crt_overlay = texture(pixel_texture, crt_uv);
	
	vec4 base_texture = texture(screen_texture, UV);
	
	vec2 offset = vec2(2.0, 2.0) * SCREEN_PIXEL_SIZE;
	vec2 UV_new = UV - mod(UV, SCREEN_PIXEL_SIZE * 4.) + offset;
	vec3 tex = texture(screen_texture, UV_new).rgb;
	
	//COLOR.rgb = tex;

	//COLOR = averaged_color;
   	//COLOR.rgb = crt_overlay.rgb * averaged_color.rgb;
	COLOR.rgb = mix(tex.rgb, crt_overlay.rgb * tex.rgb, overlay_intensity) * base_texture.a;
	//COLOR.rgb = base_texture.rgb * base_texture.a;
	COLOR.a = 1.;
}