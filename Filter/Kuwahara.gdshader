shader_type canvas_item;


uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D _TFM;
uniform int _KernelSize;
uniform float _Zeta;
uniform float _ZeroCrossing;
uniform int _N;
uniform float _Hardness;
uniform float _Q;
float gaussian(float sigma, float pos) {
    return (1.0f / sqrt(2.0f * PI * sigma * sigma)) * exp(-(pos * pos) / (2.0f * sigma * sigma));
}


void fragment()
{
	
 	 float alpha =  texture(screen_texture, SCREEN_UV).w;
                vec4 t = texture(_TFM, SCREEN_UV);

                int kernelRadius = _KernelSize / 2;
                float a = float((kernelRadius)) * clamp((alpha + t.w) / alpha, 0.1f, 2.0f);
                float b = float((kernelRadius)) * clamp(alpha / (alpha + t.w), 0.1f, 2.0f);
                
                float cos_phi = cos(t.z);
                float sin_phi = sin(t.z);

                mat2 R = mat2(vec2(cos_phi, -sin_phi),
                              vec2(sin_phi, cos_phi));

                mat2 S = mat2(vec2(0.5f / a, 0.0f),
                              vec2(0.0f, 0.5f / b));

                mat2 SR = S * R;

                int max_x = int(sqrt(a * a * cos_phi * cos_phi + b * b * sin_phi * sin_phi));
                int max_y = int(sqrt(a * a * sin_phi * sin_phi + b * b * cos_phi * cos_phi));

                //float zeta = 2.0f / (kernelRadius);
                float zeta = _Zeta;

                float zeroCross = _ZeroCrossing;
                float sinZeroCross = sin(zeroCross);
                float eta = (zeta + cos(zeroCross)) / (sinZeroCross * sinZeroCross);
            
                vec4 m[8];
                vec3 s[8];

                for (int k = 0; k < _N; ++k) {
                    m[k] = vec4(0.0f);
                    s[k] = vec3(0.0f);
                }

            
                for (int y = -max_y; y <= max_y; ++y) {
               
                    for (int x = -max_x; x <= max_x; ++x) {
                        vec2 v = SR * vec2(float(x), float(y));
                        if (dot(v, v) <= 0.25f) {
                            vec3 c = texture(screen_texture, SCREEN_UV + vec2(float(x), float(y)) * SCREEN_PIXEL_SIZE.xy).rgb;
                            c = clamp(c,0,1);
                            float sum = 0.0;
                            float w[8];
                            float z, vxx, vyy;
                            
                            /* Calculate Polynomial Weights */
                            vxx = zeta - eta * v.x * v.x;
                            vyy = zeta - eta * v.y * v.y;
                            z = max(0, v.y + vxx); 
                            w[0] = z * z;
                            sum += w[0];
                            z = max(0, -v.x + vyy); 
                            w[2] = z * z;
                            sum += w[2];
                            z = max(0, -v.y + vxx); 
                            w[4] = z * z;
                            sum += w[4];
                            z = max(0, v.x + vyy); 
                            w[6] = z * z;
                            sum += w[6];
                            v = sqrt(2.0f) / 2.0f * vec2(v.x - v.y, v.x + v.y);
                            vxx = zeta - eta * v.x * v.x;
                            vyy = zeta - eta * v.y * v.y;
                            z = max(0, v.y + vxx); 
                            w[1] = z * z;
                            sum += w[1];
                            z = max(0, -v.x + vyy); 
                            w[3] = z * z;
                            sum += w[3];
                            z = max(0, -v.y + vxx); 
                            w[5] = z * z;
                            sum += w[5];
                            z = max(0, v.x + vyy); 
                            w[7] = z * z;
                            sum += w[7];
                            
                            float g = exp(-3.125f * dot(v,v)) / sum;
                            
                            for (int k = 0; k < 8; ++k) {
                                float wk = w[k] * g;
                                m[k] += vec4(c * wk, wk);
                                s[k] += c * c * wk;
                            }
                        }
                    }
                }

                vec4 output = vec4(0);
                for (int k = 0; k < _N; ++k) {
                    m[k].rgb /= m[k].w;
                    s[k] = abs(s[k] / m[k].w - m[k].rgb * m[k].rgb);

                    float sigma2 = s[k].r + s[k].g + s[k].b;
                    float w = 1.0f / (1.0f + pow(_Hardness * 1000.0f * sigma2, 0.5f * _Q));

                    output += vec4(m[k].rgb * w, w);
                }
                
        COLOR =  clamp(output / output.w,0,1);
}