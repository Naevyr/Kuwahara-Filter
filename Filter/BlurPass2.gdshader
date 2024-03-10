shader_type canvas_item;


uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

float gaussian(float sigma, float pos) {
        return (1.0f / sqrt(2.0f * PI * sigma * sigma)) * exp(-(pos * pos) / (2.0f * sigma * sigma));
    }

float atan2(float y, float x) {
  if (x > 0.0) {
    return atan(y / x);
  } else if (x < 0.0 && y >= 0.0) {
    return atan(y / x) + 3.14159265359;
  } else if (x < 0.0 && y < 0.0) {
    return atan(y / x) - 3.14159265359;
  } else if (x == 0.0 && y > 0.0) {
    return 1.57079632679;
  } else if (x == 0.0 && y < 0.0) {
    return -1.57079632679;
  } else {
    return 0.0;
  }
}
    
void fragment()
{
	 int kernelRadius = 5;

            vec4 col = vec4(0);
            float kernelSum = 0.0f;

            for (int y = -kernelRadius; y <= kernelRadius; ++y) {
                vec4 c = texture(screen_texture, SCREEN_UV + vec2(0.0, float(y)) * TEXTURE_PIXEL_SIZE);
                float gauss = gaussian(2.0f, float(y));

                col += c * gauss;
                kernelSum += gauss;
            }

            vec3 g = col.rgb / kernelSum;

            float lambda1 = 0.5f * (g.y + g.x + sqrt(g.y * g.y - 2.0f * g.x * g.y + g.x * g.x + 4.0f * g.z * g.z));
            float lambda2 = 0.5f * (g.y + g.x - sqrt(g.y * g.y - 2.0f * g.x * g.y + g.x * g.x + 4.0f * g.z * g.z));

            vec2 v = vec2(lambda1 - g.x, -g.z);
            vec2 t = length(v) > 0.0 ? normalize(v) : vec2(0.0f, 1.0f);
            float phi = -atan2(t.y, t.x);

            float A = (lambda1 + lambda2 > 0.0f) ? (lambda1 - lambda2) / (lambda1 + lambda2) : 0.0f;
            
            COLOR =  vec4(t, phi, A);
}
