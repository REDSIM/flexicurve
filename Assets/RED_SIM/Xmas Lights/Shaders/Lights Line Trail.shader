// Originally Made with Amplify Shader Editor by RED_SIM
// Available at the Unity Asset Store - http://u3d.as/y3X 
// vert, geom functions Copyright 2019 Lyuma, licensed under MIT.
Shader "RED_SIM/Lights Line Trail"
{
	Properties
	{
		[NoScaleOffset]_GradientMap("Gradient Map", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,0)
		_HueShiftSpeed("Hue Shift Speed", Range( 0 , 2)) = 0
		_WireColor("Wire Color", Color) = (0.004817439,0.1397059,0,0)
		_BulbColor("Bulb Color", Color) = (0.004817439,0.1397059,0,0)
		_Brightness("Brightness", Float) = 1
		_Speed("Speed", Float) = 2
		_WireSmoothness("Wire Smoothness", Range( 0 , 1)) = 0.5
		_BulbSmoothness("Bulb Smoothness", Range( 0 , 1)) = 0.5
		_Scale("Scale", Float) = 1

		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
	Pass {
		Tags { "LightMode"="ForwardBase" }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"

		#pragma target 4.0
		#pragma vertex vert
		#pragma fragment frag
		#pragma geometry geom

		uniform float4 _WireColor;
		uniform float4 _BulbColor;
		uniform float _HueShiftSpeed;
		uniform sampler2D _GradientMap;
		uniform float _Speed;
		uniform float _Scale;
		uniform float _Brightness;
		uniform float4 _Color;
		uniform float _WireSmoothness;
		uniform float _BulbSmoothness;

		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

float rand_1_05(in float2 uv)
{
    return abs(dot(frac(sin(dot(uv ,float2(12.9898,78.233)*2.0)) * 43758.5453), 0.5));
}

        struct v2g {
            float4 vertex : POSITION;
            float2 texcoord : TEXCOORD0;
        };

        v2g vert (float4 vertex : POSITION, float2 texcoord : TEXCOORD0) {
            v2g o = (v2g)0;
            o.vertex = vertex;
            o.texcoord = texcoord;
            return o;
        }

        struct g2f {
            float4 pos : SV_Position;
            float3 texcoordColor : TEXCOORD0;
			float3 worldPos : TEXCOORD1;
			float3 worldNormal : TEXCOORD2;
        };

        void emitVertex(inout TriangleStream<g2f> outTris, float3x3 mat, float4 startPos, float3 relPos, float3 uvw) {
            g2f o;
			float3 relVert = mul(mat, relPos * startPos.w);
            o.pos = UnityObjectToClipPos(relVert + startPos.xyz);
            o.texcoordColor = uvw;
			o.worldNormal = UnityObjectToWorldNormal(normalize(relVert));
			o.worldPos = mul(unity_ObjectToWorld, float4(relVert + startPos.xyz, 1)).xyz;
            outTris.Append(o);
        }

        void emitVertex2(inout TriangleStream<g2f> outTris, float3x3 mat, float4 startPos, float4 endPos, float3 relPos, float3 uvw) {
            emitVertex(outTris, mat, startPos, relPos, uvw);
            emitVertex(outTris, mat, endPos, relPos, uvw);
        }

// Rotation with angle (in radians) and axis - keijiro
float3x3 AngleAxis3x3(float angle, float3 axis)
{
    float c, s;
    sincos(angle, s, c);

    float t = 1 - c;
    float x = axis.x;
    float y = axis.y;
    float z = axis.z;

    return float3x3(
        t * x * x + c,      t * x * y - s * z,  t * x * z + s * y,
        t * x * y + s * z,  t * y * y + c,      t * y * z - s * x,
        t * x * z - s * y,  t * y * z + s * x,  t * z * z + c
    );
}

        [maxvertexcount(10+8)]
        void geom (triangle v2g IN[3], inout TriangleStream<g2f> outTris, uint pid : SV_PrimitiveID) {
            float4 startPos = float4(IN[0].vertex.xyz, 1);
            float4 endPos = float4(distance(IN[0].vertex.xyz, IN[1].vertex.xyz) > distance(IN[0].vertex.xyz, IN[2].vertex.xyz) ? IN[1].vertex.xyz : IN[2].vertex.xyz, 1);
			if (distance(startPos, endPos) > 500.0) {
				return;
			}
            float3 up = float3(0,1,0);
            float3 forward = normalize(endPos.xyz - startPos.xyz);
            if (abs(forward.y) > 0.95) {
                up = float3(1,0,0);
            }
            if (pid % 2 == 0) {
				startPos.w = 0.5;
				float3 xup = up;
                up = forward;
				forward = xup;
				//up = mul(AngleAxis3x3(1726.23 * rand_1_05(IN[0].vertex.xy + IN[0].vertex.z), xup), up);
                // forward = mul(AngleAxis3x3(1726.23 * rand_1_05(IN[0].vertex.xy + IN[0].vertex.z), forward), xup);
            }
            float3 side = cross(up, forward);
			up = cross(side, forward);
            if (pid % 2 == 0) {
				float noise = 0.5 + 0.5 * pow(sin(dot(13.7, IN[0].vertex.xyz)), 3);
				startPos.xyz = lerp(startPos.xyz, endPos.xyz, noise);
                forward = mul(AngleAxis3x3(dot(173.3, IN[0].vertex.xyz), up), forward);
				side = cross(up, forward);
                endPos = float4(startPos.xyz + forward * .02, 0.65);
			}
            float3x3 mat = float3x3(side.x, up.x, forward.x, side.y, up.y, forward.y, side.z, up.z, forward.z);

            float3 uvx = float3(IN[0].texcoord.x, 0, 0);
            // (pid % 2 != 0 ? 1 : 0)
            emitVertex2(outTris, mat, startPos, endPos, float3(0, 0.003, 0), uvx);
            emitVertex2(outTris, mat, startPos, endPos, float3(-0.003 * 0.86, -0.0015, 0), uvx);
            emitVertex2(outTris, mat, startPos, endPos, float3(0.003 * 0.86, -0.0015, 0), uvx);
            emitVertex2(outTris, mat, startPos, endPos, float3(0, 0.003, 0), uvx);

            if ((pid % 2) == 0) {
                uvx = float3(IN[0].texcoord.x, 1 - IN[0].texcoord.x, 1);
                outTris.RestartStrip();
                float4 enderPos = float4(lerp(startPos.xyz, endPos.xyz, 1.3), 0.3);
                emitVertex2(outTris, mat, endPos, enderPos, float3(0, 0.003, 0), uvx);
                emitVertex2(outTris, mat, endPos, enderPos, float3(-0.003 * 0.86, -0.0015, 0), uvx);
                emitVertex2(outTris, mat, endPos, enderPos, float3(0.003 * 0.86, -0.0015, 0), uvx);
                emitVertex2(outTris, mat, endPos, enderPos, float3(0, 0.003, 0), uvx);
                emitVertex(outTris, mat, enderPos, float3(-0.003 * 0.86, -0.0015, 0), uvx);
                emitVertex(outTris, mat, enderPos, float3(0.003 * 0.86, -0.0015, 0), uvx);
                // draw bulb
            }
        }

		float4 frag( g2f i ) : SV_Target
		{
			float4 lerpResult6 = lerp( _WireColor , _BulbColor , i.texcoordColor.z);
			float3 o_Albedo = lerpResult6.rgb;
			float mulTime40 = _Time.y * _HueShiftSpeed;
			float mulTime9 = _Time.y * -_Speed;
			float2 appendResult31 = (float2(_Scale , 1.0));
			float2 uv_TexCoord8 = i.texcoordColor.xy * appendResult31;
			float2 appendResult26 = (float2(( mulTime9 + uv_TexCoord8.x ) , uv_TexCoord8.y));
			float3 hsvTorgb42 = RGBToHSV( ( tex2D( _GradientMap, appendResult26 ) * _Brightness * _Color * i.texcoordColor.z ).rgb );
			float3 hsvTorgb43 = HSVToRGB( float3(( mulTime40 + hsvTorgb42.x ),hsvTorgb42.y,hsvTorgb42.z) );
			float3 o_Emission = hsvTorgb43;
			float lerpResult16 = lerp( _WireSmoothness , _BulbSmoothness , i.texcoordColor.z);
			float o_Smoothness = lerpResult16;
			//o.Alpha = 1;
			//return float4(lerpResult6.rgb * ShadeSH9(float3(0,0,0)) + hsvTorgb43, 1);

			float3 normal = normalize(i.worldNormal);
			float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
			UnityLight light;
			light.color = _LightColor0.rgb;
			light.dir = _WorldSpaceLightPos0.xyz;
			light.ndotl = DotClamped(normal, _WorldSpaceLightPos0.xyz);
			UnityIndirect indirectLight = (UnityIndirect)0;
			indirectLight.diffuse += max(0, ShadeSH9(float4(normal, 1)));
			float3 reflectionDir = reflect(-viewDir, normal);
			float4 envSample = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflectionDir);
			indirectLight.specular = DecodeHDR(envSample, unity_SpecCube0_HDR);

			return UNITY_BRDF_PBS(
				o_Albedo, (1 - i.texcoordColor.z) * o_Albedo,
				0.9, o_Smoothness,
				normal, viewDir,
				light, indirectLight
			) + float4(o_Emission, 0);
		}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
}