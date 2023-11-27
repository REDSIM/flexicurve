// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Garland"
{
	Properties
	{
		_Wire("Wire", 2D) = "black" {}
		_Lamp("Lamp", 2D) = "white" {}
		_LampMask("Lamp Mask", 2D) = "white" {}
		_WireColor("Wire Color", Color) = (1,1,1,0)
		_LampColor("Lamp Color", Color) = (1,1,1,0)
		[HDR]_Color("Color", Color) = (1,0.6317914,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float3 uv_texcoord;
		};

		uniform sampler2D _Wire;
		uniform float4 _Wire_ST;
		uniform float4 _WireColor;
		uniform sampler2D _Lamp;
		uniform float4 _Lamp_ST;
		uniform float4 _LampColor;
		uniform sampler2D _LampMask;
		uniform float4 _LampMask_ST;
		uniform float4 _Color;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Wire = i.uv_texcoord * _Wire_ST.xy + _Wire_ST.zw;
			float2 uv_Lamp = i.uv_texcoord * _Lamp_ST.xy + _Lamp_ST.zw;
			float LampMask26 = sign( i.uv_texcoord.z );
			float4 lerpResult5 = lerp( ( tex2D( _Wire, uv_Wire ) * _WireColor ) , ( tex2D( _Lamp, uv_Lamp ) * _LampColor ) , LampMask26);
			o.Albedo = lerpResult5.rgb;
			float2 uv_LampMask = i.uv_texcoord * _LampMask_ST.xy + _LampMask_ST.zw;
			float mulTime14 = _Time.y * 0.1;
			o.Emission = ( ( tex2D( _LampMask, uv_LampMask ).r * LampMask26 * saturate( sin( ( ( i.uv_texcoord.z + mulTime14 ) * 50.0 ) ) ) ) * _Color ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.SamplerNode;1;-991.9999,-151.5;Inherit;True;Property;_Wire;Wire;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;5;-104.6371,-147.5044;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;4;-1011.192,41.50021;Inherit;True;Property;_Lamp;Lamp;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;319.1998,-148;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Garland;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-443.2764,-151.8731;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;19;-710.4766,-91.07318;Inherit;False;Property;_WireColor;Wire Color;3;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;21;-705.0472,99.29581;Inherit;False;Property;_LampColor;Lamp Color;4;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-468.8765,35.32684;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-265.4984,58.75486;Inherit;False;26;LampMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-1574.032,507.3997;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-1277.1,577.6236;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1145.901,577.2236;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;50;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;15;-985.3004,575.4235;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;14;-1540.101,665.2236;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;24;-859.3212,574.5965;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-657.9257,276.3031;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-929.0176,482.0347;Inherit;False;LampMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;6;-1278.182,484.7033;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;17;-1016.821,254.3652;Inherit;True;Property;_LampMask;Lamp Mask;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-378.8589,354.1143;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;30;-622.2189,448.7543;Inherit;False;Property;_Color;Color;5;1;[HDR];Create;True;0;0;0;False;0;False;1,0.6317914,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;5;0;20;0
WireConnection;5;1;22;0
WireConnection;5;2;27;0
WireConnection;0;0;5;0
WireConnection;0;2;28;0
WireConnection;20;0;1;0
WireConnection;20;1;19;0
WireConnection;22;0;4;0
WireConnection;22;1;21;0
WireConnection;10;0;2;3
WireConnection;10;1;14;0
WireConnection;13;0;10;0
WireConnection;15;0;13;0
WireConnection;24;0;15;0
WireConnection;18;0;17;1
WireConnection;18;1;26;0
WireConnection;18;2;24;0
WireConnection;26;0;6;0
WireConnection;6;0;2;3
WireConnection;28;0;18;0
WireConnection;28;1;30;0
ASEEND*/
//CHKSM=1E1F9D129DA6A44E4074CD8BB932D9FCD4CF931B