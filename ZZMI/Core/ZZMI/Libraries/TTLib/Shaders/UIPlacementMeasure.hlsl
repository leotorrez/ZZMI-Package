// Resolve the native four-vertex UI quad to a physical backbuffer rectangle.
Buffer<float> Quad : register(t0);
RWBuffer<float4> Record : register(u0);
Texture1D<float4> IniParams : register(t120);

#define ARGS IniParams[94]

cbuffer ModelCB : register(b0) { float4 Model[4]; }
cbuffer ProjectionCB : register(b1) { float4 Projection[21]; }

[numthreads(1, 1, 1)]
void main()
{
    uint stride = (uint)(ARGS.x + 0.5);
    float2 target = max(ARGS.yz, 1.0);
    if (stride < 3 || stride > 32)
        return;

    float2 lo = 1e30;
    float2 hi = -1e30;

    [unroll]
    for (uint i = 0; i < 4; i++)
    {
        uint base = i * stride;
        float4 model = Model[0] * Quad[base]
                     + Model[1] * Quad[base + 1]
                     + Model[2] * Quad[base + 2]
                     + Model[3];
        float4 clip = Projection[17] * model.x
                    + Projection[18] * model.y
                    + Projection[19] * model.z
                    + Projection[20] * model.w;

        if (abs(clip.w) <= 1e-6)
            return;

        float2 pixel = float2(
            (clip.x / clip.w * 0.5 + 0.5) * target.x,
            (0.5 - clip.y / clip.w * 0.5) * target.y);
        lo = min(lo, pixel);
        hi = max(hi, pixel);
    }

    float2 size = hi - lo;
    if (size.x < 1.0 || size.y < 1.0 || size.x >= 32768.0 || size.y >= 32768.0)
        return;

    Record[0] = float4(1, 1, ARGS.w, 0);
    Record[1] = float4(lo, size);
}
