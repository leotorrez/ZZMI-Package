#include "LayerCommon.hlsli"

void main(float4 position : SV_Position, float4 uv_pack : TEXCOORD0,
          out float4 target : SV_Target0)
{
    target = BuildLayer(uv_pack.xy);
}
