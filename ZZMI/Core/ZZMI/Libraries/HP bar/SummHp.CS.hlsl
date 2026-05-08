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
Buffer<float4> cb : register(t0);

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
#define total IniParams[1].y

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
	accumulator acc = data.hp_acc;
	if (acc.counter < 3 && cb[12].x > 0.39 && cb[12].x < 0.61)
	{
		float positionX = vb0[first_vertex].position.x;
		int value = floor((cb[11].y + cb[11].z) * 100);
		
		int3 hp = data.hp;
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