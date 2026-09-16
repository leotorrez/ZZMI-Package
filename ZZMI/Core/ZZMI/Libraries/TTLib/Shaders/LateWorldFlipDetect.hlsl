// Measure the Y orientation of the native final-3D transfer.

struct VS_OUT
{
    float4 pos : SV_Position;
    float2 uv0 : TEXCOORD0;
    float4 uv1 : TEXCOORD1;
};

struct GS_OUT
{
    float4 pos : SV_Position;
    float data : TEXCOORD0;
};

#ifdef GEOMETRY_SHADER
[maxvertexcount(3)]
void main(triangle VS_OUT input[3], uint primitive_id : SV_PrimitiveID,
          inout TriangleStream<GS_OUT> stream)
{
    if (primitive_id > 0u)
        return;

    float delta_pos_y = input[1].pos.y - input[0].pos.y;
    float delta_uv_y = input[1].uv0.y - input[0].uv0.y;

    if (abs(delta_pos_y) < 1e-4)
    {
        delta_pos_y = input[2].pos.y - input[0].pos.y;
        delta_uv_y = input[2].uv0.y - input[0].uv0.y;
    }

    GS_OUT output;
    output.data = delta_pos_y * delta_uv_y > 1e-6 ? 1.0 : 0.0;
    output.pos = float4(-1.0,  3.0, 0.0, 1.0); stream.Append(output);
    output.pos = float4(-1.0, -1.0, 0.0, 1.0); stream.Append(output);
    output.pos = float4( 3.0, -1.0, 0.0, 1.0); stream.Append(output);
    stream.RestartStrip();
}
#endif

#ifdef PIXEL_SHADER
void main(GS_OUT input, out float4 target : SV_Target0)
{
    target = float4(input.data, 0.0, 0.0, 0.0);
}
#endif
