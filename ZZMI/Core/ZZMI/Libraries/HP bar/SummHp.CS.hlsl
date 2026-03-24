RWBuffer<float> u0 : register(u0);
Buffer<float4> cb0 : register(t0);

#define cmp -
Texture1D<float4> IniParams : register(t120);

#define index IniParams[1].x
#define total IniParams[1].y

[numthreads(1, 1, 1)]
void main()
{
	u0[index] = floor((cb0[11].y + cb0[11].z) * 100);
	switch (total) {
		case 1:
			u0[2] = (u0[0] * pow(101, 2)) + (100 * 101) + 100;
			break;
		case 2:
			u0[2] = (u0[0] * pow(101, 2)) + (u0[1] * 101) + 100;
			break;
		case 3:
			u0[2] = (u0[0] * pow(101, 2)) + (u0[1] * 101) + u0[2];
			break;
	};
}