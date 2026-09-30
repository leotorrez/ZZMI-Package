// PetraScyll, LeoTorrez, SinOfSeven
// Input:
// vanilla cs-cb0 = offset, count, multiplier, unused
//
// Output:
// Updates the multiplier for the given SK that attempted to be applied and
// skips the vanilla application in favor of modded application later

// struct offset_t
//{
//     uint old_offset;
//     uint old_count;
//     uint new_offset;
//     uint new_count;
// }
struct cb0_t {
  uint offset;
  uint count;
  float multiplier;
  uint unused;
};
cbuffer cb0 : register(b0) { cb0_t cb0[1]; };

Buffer<uint4> OffsetB : register(t100);
RWBuffer<float> MultipliersRW : register(u7);

[numthreads(1, 1, 1)] void main(uint3 ThreadId : SV_DispatchThreadID) {
  uint len = 0;
  uint i = ThreadId.x;
  OffsetB.GetDimensions(len);
  for (uint i = 0; i < len; i++) {
    if (cb0[0].offset == OffsetB[i][0] && cb0[0].count == OffsetB[i][1]) {
      MultipliersRW[i] = cb0[0].multiplier;
      break;
    }
  }
}
