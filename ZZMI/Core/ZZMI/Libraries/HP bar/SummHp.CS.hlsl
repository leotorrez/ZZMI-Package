struct accumulator
{
	uint counter;
	float summ;
};
struct stored
{
	uint3 hp;
	int3 hp_pos;
	accumulator hp_acc;

	uint3 id;
	int3 id_pos;
	accumulator id_acc;
};
RWStructuredBuffer<stored> u0 : register(u0);

Buffer<float> vb0 : register(t0);
cbuffer cb1 : register(b1)
{
	float4 cb1[29];
}

#define cmp -
Texture1D<float4> IniParams : register(t120);


#define first_vertex	IniParams[1].x
#define total_raw		IniParams[1].y
#define stride			IniParams[1].z


[numthreads(1, 1, 1)]
void main()
{
	float z = cb1[12].z;
	if (z <= 0.39 || z >= 0.61)
		return;

	stored data = u0[0];

	uint counter = data.hp_acc.counter;
	if (counter >= 3)
		return;

	uint total = (uint)total_raw;

	uint index = first_vertex * stride / 4;
	int positionX = vb0[index];
	uint value = (cb1[11].z + cb1[11].w) * 100.0 + 0.5;

	uint3 hp = data.hp;
	int3 pos = data.hp_pos;

	if (counter == 0)
	{
		hp.x = value;
		pos.x = positionX;
	}
	else if (counter == 1)
	{
		hp.y = value;
		pos.y = positionX;

		if (positionX < pos.x)
		{
			uint th = hp.x;
			hp.x = hp.y;
			hp.y = th;

			int tp = pos.x;
			pos.x = pos.y;
			pos.y = tp;
		}
	}
	else
	{
		hp.z = value;
		pos.z = positionX;

		if (positionX < pos.y)
		{
			uint th = hp.y;
			hp.y = hp.z;
			hp.z = th;

			int tp = pos.y;
			pos.y = pos.z;
			pos.z = tp;

			if (positionX < pos.x)
			{
				th = hp.x;
				hp.x = hp.y;
				hp.y = th;

				tp = pos.x;
				pos.x = pos.y;
				pos.y = tp;
			}
		}
	}

	data.hp = hp;
	data.hp_pos = pos;

	counter++;
	data.hp_acc.counter = counter;

	if (counter == total)
	{
		uint packed = hp.x << 14;

		if (total > 1)
			packed |= hp.y << 7;
		else
			packed |= 12900u;

		if (total > 2)
			packed |= hp.z;
		else if (total == 2)
			packed |= 100u;

		data.hp_acc.summ = packed;
	}

	u0[0] = data;
}