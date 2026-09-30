// LeoTorrez, SinsOfSeven
struct Delta {
  uint vertexIndex;
  float3 pos;
  float3 norm;
  float3 tan;
};

struct Identity {
  uint old_offset;
  uint old_count;
  uint offset;
  uint count;
};

RWByteAddressBuffer output : register(u7);
StructuredBuffer<Delta> deltas : register(t100);
StructuredBuffer<Identity> identity : register(t101);
Buffer<float> multipliers : register(t102);
Buffer<float> overrides : register(t103);
RWBuffer<float4> debugBuffer : register(u6);

void InterlockedAddFloat(RWByteAddressBuffer buffer, uint addr, float value) {
  // https://www.gamedev.net/forums/topic/613648-dx11-interlockedadd-on-floats-in-pixel-shader-workaround/
  uint comp, orig = buffer.Load(addr);
  // uint iterations = 0;
  [allow_uav_condition] do {
    uint sum = asuint(asfloat(orig) + value);
    comp = orig;
    buffer.InterlockedCompareExchange(addr, comp, sum, orig);
    // iterations += 1;
  }
  while (orig != comp)
    ;
  // while (orig != comp && iterations < 16);

  // The max iterations seems unneeded after testing.
}

float GetWeightForDelta(uint deltaIndex, uint shapeKeyTotal) {
  uint left = 0;
  uint right = shapeKeyTotal - 1;
  uint mid, offset, count;
  for (uint i = 0; i < 32; ++i) {
    mid = (left + right) / 2;
    offset = (uint)identity[mid].offset;
    count = (uint)identity[mid].count;
    if (left > right) {
      break;
    }

    if (deltaIndex >= offset && deltaIndex < (offset + count)) {
      debugBuffer[i] = float4(offset, count, mid, multipliers[mid]);
      float x = overrides[mid];
      return abs(x) > 0.0001f ? x : multipliers[mid]; // Found
    }

    if (offset + count == 0) {
      // # The binary search for pain:
      // This condition is required specificically for our use case
      // when a shapekey entry in Deltas could have a count and offset of 0
      // in which case a traditional binary search would start to
      // search in the wrong direction and get lost in SOME cases
      // DO NOT DELETE THIS CONDITION YOU ARE NOT BEING SMART
      right = mid - 1;
    } else if (deltaIndex < offset) {
      right = mid - 1;
    } else {
      left = mid + 1;
    }
  }
  return 0.0; // Search failed
}

[numthreads(64, 1, 1)] void main(uint3 dispatchThreadID : SV_DispatchThreadID) {
  uint deltaIndex = dispatchThreadID.x;
  uint deltaLen, deltaStride;
  deltas.GetDimensions(deltaLen, deltaStride);
  if (deltaIndex >= deltaLen) {
    return;
  }

  Delta delta = deltas[deltaIndex];
  uint length, stride;
  identity.GetDimensions(length, stride);
  float weight = GetWeightForDelta(deltaIndex, length);

  if (abs(weight) < 0.0001f) {
    return;
  }
  uint byteOffset = delta.vertexIndex * 40;
  InterlockedAddFloat(output, byteOffset + 0, delta.pos.x * weight);
  InterlockedAddFloat(output, byteOffset + 4, delta.pos.y * weight);
  InterlockedAddFloat(output, byteOffset + 8, delta.pos.z * weight);

  InterlockedAddFloat(output, byteOffset + 12, delta.norm.x * weight);
  InterlockedAddFloat(output, byteOffset + 16, delta.norm.y * weight);
  InterlockedAddFloat(output, byteOffset + 20, delta.norm.z * weight);

  InterlockedAddFloat(output, byteOffset + 24, delta.tan.x * weight);
  InterlockedAddFloat(output, byteOffset + 28, delta.tan.y * weight);
  InterlockedAddFloat(output, byteOffset + 32, delta.tan.z * weight);

  return;
}
