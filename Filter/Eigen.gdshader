shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment()
{
    vec2 d = SCREEN_PIXEL_SIZE;

    vec3 Sx = (
        1.0f * texture(screen_texture, SCREEN_UV + vec2(-d.x, -d.y)).rgb +
        2.0f * texture(screen_texture, SCREEN_UV + vec2(-d.x,  0.0)).rgb +
        1.0f * texture(screen_texture, SCREEN_UV + vec2(-d.x,  d.y)).rgb +
        -1.0f * texture(screen_texture, SCREEN_UV + vec2(d.x, -d.y)).rgb +
        -2.0f * texture(screen_texture, SCREEN_UV + vec2(d.x,  0.0)).rgb +
        -1.0f * texture(screen_texture, SCREEN_UV + vec2(d.x,  d.y)).rgb
    ) / 4.0f;

    vec3 Sy = (
        1.0f * texture(screen_texture, SCREEN_UV + vec2(-d.x, -d.y)).rgb +
        2.0f * texture(screen_texture, SCREEN_UV + vec2( 0.0, -d.y)).rgb +
        1.0f * texture(screen_texture, SCREEN_UV + vec2( d.x, -d.y)).rgb +
        -1.0f * texture(screen_texture, SCREEN_UV + vec2(-d.x, d.y)).rgb +
        -2.0f * texture(screen_texture, SCREEN_UV + vec2( 0.0, d.y)).rgb +
        -1.0f * texture(screen_texture, SCREEN_UV + vec2( d.x, d.y)).rgb
    ) / 4.0f;

    
    COLOR = vec4(dot(Sx, Sx), dot(Sy, Sy), dot(Sx, Sy), 1.0f);
}