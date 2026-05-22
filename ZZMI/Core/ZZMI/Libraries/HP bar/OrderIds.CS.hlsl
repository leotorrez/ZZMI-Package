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


#define cmp -
Texture1D<float4> IniParams : register(t120);


#define first_vertex IniParams[1].x
#define total IniParams[1].y
#define value IniParams[1].z

void swap(inout int a, inout int b)
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
	accumulator acc = data.id_acc;
	if (acc.counter < 3)
	{
		uint index = first_vertex;
		if (vb0[5] == -1) {
			index = index * 76 / 4;
		} else if (vb0[1] == 0) {
			index = index * 20 / 4;
		}
		float positionX = vb0[index];

		uint3 id = data.id;
		int3 pos = data.id_pos;

		switch (acc.counter)
		{
			case 0:
				id.x = value;
				pos.x = positionX;
				break;
			case 1:
				id.y = value;
				pos.y = positionX;
				if (positionX < pos.x)
				{
					swap(id.x, id.y);
					swap(pos.x, pos.y);
				}
				break;
			case 2:
				id.z = value;
				pos.z = positionX;
				if (positionX < pos.y)
				{
					swap(id.y, id.z);
					swap(pos.y, pos.z);

					if (positionX < pos.x)
					{
						swap(id.x, id.y);
						swap(pos.x, pos.y);
					}
				}
				break;
		}

		data.id = id;
		data.id_pos = pos;

		acc.counter++;

		if (acc.counter == total)
		{
			switch (total)
			{
				case 1:
					acc.summ = (id.x * 10201) + 0;
					break;
				case 2:
					acc.summ = (id.x * 10201) + (id.y * 101) + 0;
					break;
				case 3:
					acc.summ = (id.x * 10201) + (id.y * 101) + id.z;
					break;
			}
		}

		data.id_acc = acc;
		u0[0] = data;
	}
}
