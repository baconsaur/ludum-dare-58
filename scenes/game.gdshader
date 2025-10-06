shader_type canvas_item;

uniform vec3 wave_color: source_color;
uniform float wave_size : hint_range(0.0, 1.0) = 0.1;
uniform float wave_frequency : hint_range(0.0, 0.1
) = 0.04;
uniform float wave_speed : hint_range(0.0, 60.0) = 20.0;
uniform float border_size : hint_range(0, 0.1) = 0.01;
uniform float edge_height : hint_range(0, 1.0) = 0.5;
uniform vec4 border_color : source_color;

void fragment() {
	float value = (1.0 - UV.y) * (1.0 - wave_size - border_size);
	vec4 color = COLOR.rgba;

	float wave_height = edge_height - (sin(UV.x / wave_frequency + TIME * wave_speed) + 1.0) / 2.0 * wave_size;

	if (value > wave_height) {
		if (value < wave_height + border_size) {
			color = border_color.rgba;
		} else {
			color.a = 0.0;
		}
	}

	COLOR = color;
}