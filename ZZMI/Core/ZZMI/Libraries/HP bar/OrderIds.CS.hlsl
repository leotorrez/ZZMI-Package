struct accumulator
{
	uint counter;
	float summ;
};
struct stored
{
	uint3 value;
	int3  pos;
	accumulator acc;
};
RWStructuredBuffer<stored> u0 : register(u0);
Buffer<float> vb0 : register(t0);

#define cmp -
Texture1D<float4> IniParams : register(t120);

#define first_vertex	IniParams[1].x
#define total_raw		IniParams[1].y
#define value_raw		IniParams[1].z
#define stride			IniParams[1].w

[numthreads(1, 1, 1)]
void main()
{
	stored data = u0[1];

	uint counter = data.acc.counter;
	if (counter >= 3)
		return;

	uint total = (uint)total_raw;

	uint index = first_vertex * stride / 4;
	int positionX = vb0[index];
	uint value = (uint)value_raw;

	uint3 id = data.value;
	int3  pos = data.pos;

	if (counter == 0)
	{
		id.x = value;
		pos.x = positionX;
	}
	else if (counter == 1)
	{
		id.y = value;
		pos.y = positionX;

		if (positionX < pos.x)
		{
			uint tid = id.x;
			id.x = id.y;
			id.y = tid;

			int  tpos = pos.x;
			pos.x = pos.y;
			pos.y = tpos;
		}
	}
	else
	{
		id.z = value;
		pos.z = positionX;

		if (positionX < pos.y)
		{
			uint tid = id.y;
			id.y = id.z;
			id.z = tid;

			int  tpos = pos.y;
			pos.y = pos.z;
			pos.z = tpos;

			if (positionX < pos.x)
			{
				tid = id.x;
				id.x = id.y;
				id.y = tid;

				tpos = pos.x;
				pos.x = pos.y;
				pos.y = tpos;
			}
		}
	}

	data.value = id;
	data.pos = pos;

	counter++;
	data.acc.counter = counter;

	if (counter == total)
	{
		uint packed = id.x << 16;

		if (total > 1)
			packed |= id.y << 8;

		if (total > 2)
			packed |= id.z;

		data.acc.summ = packed;
	}

	u0[1] = data;
}
