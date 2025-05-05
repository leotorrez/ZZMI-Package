RWBuffer<float> u0 : register(u0);
Texture2D<float4> t8 : register(t8);
Texture2D<float4> t9 : register(t9);
Texture2D<float4> t10 : register(t10);

Texture1D<float4> IniParams : register(t120);

[numthreads(1, 1, 1)]
void main(uint3 threadID: SV_DispatchThreadID){
	u0[0] = 0;
    float2 res;
	
	t10.GetDimensions(res.x, res.y);
	if (res.x != 4) {
		u0[0] = 10;
		return;
	}
	
	t9.GetDimensions(res.x, res.y);
	if (res.x != 4) {
		u0[0] = 9;
		return;
	}
	
	t8.GetDimensions(res.x, res.y);
	if (res.x != 4) {
		u0[0] = 8;
		return;
	}
}