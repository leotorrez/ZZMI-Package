struct accumulator
{
	float counter;
	float summ;
};
struct stored
{
	float3 hp;
	float3 hp_pos;
	accumulator hp_acc;

	float3 id;
	float3 id_pos;
	accumulator id_acc;
};
RWStructuredBuffer<stored> u0 : register(u0);

Buffer<float> vb0 : register(t0);
cbuffer cb1 : register(b1)
{
	float4 cb1[24];
}

#define cmp -
Texture1D<float4> IniParams : register(t120);


#define first_vertex IniParams[1].x
#define total IniParams[1].y

void swap(inout uint a, inout uint b)
{
	if (a == b) return;
	a ^= b;
	b ^= a;
	a ^= b;
}

[numthreads(1, 1, 1)]
void main()
{
	stored data = u0[0];
	accumulator acc = data.hp_acc;
	float cb_12_x = cb1[12].x;

	if (acc.counter < 3 && cb_12_x > 0.39 && cb_12_x < 0.61)
	{
		uint index = first_vertex;
		if (vb0[5] == -1) {
			index = index * 76 / 4;
		} else if (vb0[1] == 0) {
			index = index * 20 / 4;
		}
		int positionX = vb0[index];
		float2 cb_11 = cb1[11].yz;
		uint value = floor((cb_11.x + cb_11.y) * 100);

		uint3 hp = data.hp;
		int3 pos = data.hp_pos;

		switch (acc.counter)
		{
			case 0:
				hp.x = value;
				pos.x = positionX;
				break;
			case 1:
				hp.y = value;
				pos.y = positionX;
				if (positionX < pos.x)
				{
					swap(hp.x, hp.y);
					swap(pos.x, pos.y);
				}
				break;
			case 2:
				hp.z = value;
				pos.z = positionX;
				if (positionX < pos.y)
				{
					swap(hp.y, hp.z);
					swap(pos.y, pos.z);

					if (positionX < pos.x)
					{
						swap(hp.x, hp.y);
						swap(pos.x, pos.y);
					}
				}
				break;
		}

		data.hp = hp;
		data.hp_pos = pos;

		acc.counter++;

		if (acc.counter == total)
		{
			switch (total)
			{
				case 1:
					acc.summ = (hp.x * 10201) + 10200;
					break;
				case 2:
					acc.summ = (hp.x * 10201) + (hp.y * 101) + 100;
					break;
				case 3:
					acc.summ = (hp.x * 10201) + (hp.y * 101) + hp.z;
					break;
			}
		}

		data.hp_acc = acc;
		u0[0] = data;
	}
}