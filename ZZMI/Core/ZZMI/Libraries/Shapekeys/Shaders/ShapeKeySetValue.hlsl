Texture1D<float4> IniParams : register(t120);
#define SK_INDEX IniParams[0].x
#define SK_VALUE IniParams[0].y

RWBuffer<float> Overrides : register(u7);
[numthreads(1, 1, 1)] void main(uint3 ThreadId : SV_DispatchThreadID) {
  uint size;
  Overrides[(uint)SK_INDEX] = SK_VALUE;
}
