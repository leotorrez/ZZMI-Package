#ifdef VERTEX_SHADER
void main(uint vertex_id : SV_VertexID, out float4 position_out : SV_Position,
          out float2 uv_out : TEXCOORD0)
{
    float2 position;
    if (vertex_id == 0) position = float2(-1.0, -1.0);
    else if (vertex_id == 1) position = float2(-1.0, 3.0);
    else position = float2(3.0, -1.0);

    position_out = float4(position, 0.0, 1.0);
    uv_out = position * float2(0.5, -0.5) + 0.5;
}
#endif

#ifdef PIXEL_SHADER
#include "LayerCommon.hlsli"

Texture2D<float> WorldRTFlipTex : register(t29);

void main(float4 position : SV_Position, float2 uv : TEXCOORD0,
          out float4 target : SV_Target0)
{
    if (WorldRTFlipTex.Load(int3(0, 0, 0)).x > 0.5)
        uv.y = 1.0 - uv.y;
    target = BuildLayer(uv);
}
#endif
