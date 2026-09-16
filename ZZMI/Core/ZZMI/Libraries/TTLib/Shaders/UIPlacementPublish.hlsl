// Publish only a fresh placement record; absence is represented by zero.
RWBuffer<float4> Output : register(u0);
RWBuffer<float4> Record : register(u1);
Texture1D<float4> IniParams : register(t120);

#define FRAME IniParams[94].x

[numthreads(1, 1, 1)]
void main()
{
    float4 header = Record[0];
    float age = abs(header.z - FRAME);
    bool fresh = header.x > 0.5 && age < 1.5;
    Output[0] = fresh ? float4(1, 1, 0, 0) : 0;
    Output[1] = fresh ? Record[1] : 0;
}
