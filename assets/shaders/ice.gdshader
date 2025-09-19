shader_type canvas_item;

// Uniforms for customization
uniform sampler2D noise_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform float snow_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float coldness : hint_range(0.0, 1.0) = 0.7;
uniform float noise_scale : hint_range(0.1, 10.0) = 3.0;
uniform vec4 snow_color : source_color = vec4(0.95, 0.95, 1.0, 1.0);
uniform float edge_sharpness : hint_range(0.1, 10.0) = 2.5;
uniform float time_scale : hint_range(0.0, 2.0) = 0.5;
uniform vec2 wind_direction = vec2(1.0, 0.5);

// Function to generate dynamic noise UVs
vec2 get_dynamic_noise_uv(vec2 base_uv, float time) {
    // Apply scaling
    vec2 scaled_uv = base_uv * noise_scale;

    // Add time-based movement with wind direction
    scaled_uv += wind_direction * time * time_scale;

    return scaled_uv;
}

void fragment() {
    // Sample the original texture
    vec4 original_color = texture(TEXTURE, UV);

    // Calculate dynamic noise UVs
    vec2 dynamic_noise_uv = get_dynamic_noise_uv(UV, TIME);
    float noise_value = texture(noise_texture, dynamic_noise_uv).r;

    // Add a second layer of noise with different parameters for more variety
    vec2 secondary_noise_uv = get_dynamic_noise_uv(UV * 1.7 + vec2(0.5), TIME * 0.7);
    float secondary_noise = texture(noise_texture, secondary_noise_uv).g;

    // Combine noise layers
    float combined_noise = (noise_value + secondary_noise) * 0.5;

    // Calculate snow mask based on texture brightness and noise
    float brightness = dot(original_color.rgb, vec3(0.299, 0.587, 0.114));
    float snow_mask = smoothstep(0.3, 0.7, brightness + combined_noise * 0.4);
    snow_mask = pow(snow_mask, edge_sharpness) * snow_intensity;

    // Apply cold color tint (bluish)
    vec3 cold_tint = mix(vec3(1.0), vec3(0.8, 0.9, 1.2), coldness);
    vec3 base_color = original_color.rgb * cold_tint;

    // Mix between base color and snow color based on snow mask
    vec3 final_color = mix(base_color, snow_color.rgb, snow_mask);

    // Add some sparkle to the snow using noise
    float sparkle_threshold = 0.92 + sin(TIME * 5.0) * 0.03; // Animated threshold
    float sparkle = step(sparkle_threshold, combined_noise) * snow_mask * 0.4;
    final_color += vec3(sparkle);

    // Slightly desaturate areas with less snow
    float gray = dot(final_color, vec3(0.299, 0.587, 0.114));
    final_color = mix(final_color, vec3(gray), snow_mask * 0.3);

    // Maintain original alpha
    COLOR = vec4(final_color, original_color.a);
}