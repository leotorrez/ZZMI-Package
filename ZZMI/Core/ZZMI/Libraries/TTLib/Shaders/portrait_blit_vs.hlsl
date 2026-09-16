cbuffer cb1 : register(b1)
{
    float4 cb1[1];
}

cbuffer cb0 : register(b0)
{
    float4 cb0[171];
}

void main(float4 v0 : POSITION0, float2 v1 : TEXCOORD0,
          out float4 o0 : SV_POSITION0, out float4 o1 : TEXCOORD0,
          out float4 o2 : TEXCOORD1)
{
    float4 r0 = cb0[168] * v0.yyyy;
    r0 = cb0[167] * v0.xxxx + r0;
    r0 = cb0[169] * v0.zzzz + r0;
    o0 = cb0[170] + r0;
    o1 = float4(v1.xy, 0.0, 0.0);
    o2 = cb1[0].xyxy * float4(1.0, 0.0, 0.0, 1.0) + v1.xyxy;
}
