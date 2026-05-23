shader_type canvas_item;

uniform vec4 stroke_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float stroke_size = 4.0;

varying vec2 uv_expanded;

void vertex() {
    vec2 tex_size = 1.0 / TEXTURE_PIXEL_SIZE;

    // Expand quad outward in pixel units
    VERTEX += (UV * 2.0 - 1.0) * stroke_size;

    // UV coords for expanded quad
    uv_expanded = UV * ((tex_size + stroke_size * 2.0) / tex_size)
                - vec2(stroke_size) / tex_size;
}

void fragment() {
    vec2 pixel = TEXTURE_PIXEL_SIZE;

    // Original sprite alpha (0 outside texture)
    float alpha = 0.0;
    vec4 tex = vec4(0.0);

    if (uv_expanded.x >= 0.0 && uv_expanded.x <= 1.0 &&
        uv_expanded.y >= 0.0 && uv_expanded.y <= 1.0) {
        tex = texture(TEXTURE, uv_expanded);
        alpha = tex.a;
    }

    float outline = 0.0;

    for (float x = -stroke_size; x <= stroke_size; x++) {
        for (float y = -stroke_size; y <= stroke_size; y++) {
            if (length(vec2(x, y)) <= stroke_size) {
                vec2 sample_uv = uv_expanded + vec2(x, y) * pixel;

                if (sample_uv.x >= 0.0 && sample_uv.x <= 1.0 &&
                    sample_uv.y >= 0.0 && sample_uv.y <= 1.0) {
                    outline = max(outline, texture(TEXTURE, sample_uv).a);
                }
            }
        }
    }

    float stroke = outline * (1.0 - alpha);

    COLOR = mix(stroke_color, tex, alpha);
    COLOR.a = max(alpha, stroke * stroke_color.a);
}