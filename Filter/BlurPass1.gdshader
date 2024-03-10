shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
float gaussian(float sigma, float pos) {
        return (1.0f / sqrt(2.0f * PI * sigma * sigma)) * exp(-(pos * pos) / (2.0f * sigma * sigma));
    }


void fragment()
{
 			int kernelRadius = 5;

                vec4 col = vec4(0);
                float kernelSum = 0.0f;

                for (int x = -kernelRadius; x <= kernelRadius; ++x) {
                    vec4 c = texture(screen_texture, SCREEN_UV + vec2( float(x) , 0.0) * TEXTURE_PIXEL_SIZE);
                    float gauss = gaussian(2.0f, float(x));

                    col += c * gauss;
                    kernelSum += gauss;
                }

                COLOR = col / kernelSum;
}


