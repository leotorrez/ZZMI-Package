Texture1D<float4> IniParams : register(t120);
SamplerState LinearSampler : register(s0);
Texture2D<float4> ColorTex : register(t20);
Texture2D<float4> AuxTex : register(t21);
Texture2D<float4> SceneDepthTex : register(t22);
Texture2D<float4> FakeDepthTex : register(t23);
Texture2D<float4> MeshDepthTex : register(t26);

#define DEPTH_MODE IniParams[72].x
#define HAS_MESH_MASK IniParams[95].x
#define MESH_MASK_REPLACE IniParams[95].y
#define VALUE IniParams[99].x
#define HUE_SHIFT IniParams[99].y
#define SATURATION IniParams[99].z

#include "ColorCommon.hlsli"

float4 BuildLayer(float2 uv)
{
    float4 aux = AuxTex.Sample(LinearSampler, uv);
    if (aux.a < 0.5 || aux.r <= 0.0001)
        discard;

    float scene_depth = SceneDepthTex.Sample(LinearSampler, uv).x;
    float fake_depth = FakeDepthTex.Sample(LinearSampler, uv).x;

    if (HAS_MESH_MASK > 0.5)
    {
        float mesh_depth = MeshDepthTex.Sample(LinearSampler, uv).x;
        if (MESH_MASK_REPLACE > 0.5)
            scene_depth = mesh_depth;
        else if (DEPTH_MODE < 0.5)
            scene_depth = max(scene_depth, mesh_depth);
        else
            scene_depth = min(scene_depth, mesh_depth);
    }

    if (DEPTH_MODE < 1.5)
    {
        bool occluded = DEPTH_MODE < 0.5
            ? scene_depth >= fake_depth
            : scene_depth <= fake_depth;
        if (occluded)
            discard;
    }

    float3 color = TTL_AdjustColor(
        ColorTex.Sample(LinearSampler, uv).rgb,
        VALUE, HUE_SHIFT, SATURATION);

    #ifdef TTL_NATIVE_REVEALAGE
        return float4(color, 1.0 - saturate(aux.r));
    #else
        return float4(color, saturate(aux.r));
    #endif
}
