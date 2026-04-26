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
Buffer<float4> cb0 : register(t0);


struct vb0_semantic
{
    float3 position;
	float3 normal;
	
    half2 tangent;
    half2 color;
	
    float2 texcoord;
    float2 texcoord1;
    float2 texcoord2;
    float2 texcoord3;
	
    half2 texcoord4;
    half2 texcoord5;
    half2 texcoord6;
    half2 texcoord7;

    half2 blend_weights;
    half2 blend_indices;
};
StructuredBuffer<vb0_semantic> vb0 : register(t1);


#define cmp -
Texture1D<float4> IniParams : register(t120);


#define first_vertex IniParams[1].x
#define value IniParams[1].y
#define total IniParams[1].z

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
		float positionX = vb0[first_vertex].position.x;

		int3 id = data.id;
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
					acc.summ = (id.x * 2601) + 0;
					break;
				case 2:
					acc.summ = (id.x * 2601) + (id.y * 51) + 0;
					break;
				case 3:
					acc.summ = (id.x * 2601) + (id.y * 51) + id.z;
					break;
			}
		}

		data.id_acc = acc;
		
		u0[0] = data;
	}
}