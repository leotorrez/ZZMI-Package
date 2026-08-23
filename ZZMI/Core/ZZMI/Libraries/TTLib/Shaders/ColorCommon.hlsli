float3 TTL_RgbToHsv(float3 c)
{
    float4 k = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, k.wz), float4(c.gb, k.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float3 TTL_HsvToRgb(float3 c)
{
    float4 k = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + k.xyz) * 6.0 - k.www);
    return c.z * lerp(k.xxx, saturate(p - k.xxx), c.y);
}

float3 TTL_AdjustColor(float3 color, float value, float hue_shift, float saturation)
{
    float3 hsv = TTL_RgbToHsv(color);
    hsv.x = frac(hsv.x + hue_shift);
    hsv.y = saturate(hsv.y * max(saturation, 0.0));
    hsv.z *= max(value, 0.0);
    return TTL_HsvToRgb(hsv);
}
