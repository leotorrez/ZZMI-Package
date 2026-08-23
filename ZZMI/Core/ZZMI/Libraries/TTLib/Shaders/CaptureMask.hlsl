// TTL Reforged: encode per-draw opacity into an auxiliary render target.

Texture1D<float4> IniParams : register(t120);
Texture2D<float4> MaskTex : register(t69);
SamplerState LinearSampler : register(s0);

#define OPACITY IniParams[69].w
#define MASK_CHANNEL IniParams[73].x
#define MASK_INVERT IniParams[73].y
#define DISCARD_THRESHOLD IniParams[73].z

float SelectMask(float4 value)
{
    float mask = value.r;
    if (MASK_CHANNEL == 1.0) mask = value.g;
    if (MASK_CHANNEL == 2.0) mask = value.b;
    if (MASK_CHANNEL == 3.0) mask = value.a;
    if (MASK_INVERT != 0.0) mask = 1.0 - mask;
    return saturate(mask);
}

void main(float4 uv_pack : TEXCOORD0, out float4 target : SV_Target0)
{
    uint width = 0, height = 0;
    MaskTex.GetDimensions(width, height);

    float mask = 0.0;
    if (width > 0 && height > 0)
        mask = SelectMask(MaskTex.Sample(LinearSampler, uv_pack.xy));

    float threshold = DISCARD_THRESHOLD > 0.0 ? DISCARD_THRESHOLD : 0.999;
    float coverage = mask >= threshold ? 0.0 : (1.0 - mask) * saturate(OPACITY);

    // R = final opacity, A = geometry-present marker.
    target = float4(coverage, 0.0, 0.0, 1.0);
}

