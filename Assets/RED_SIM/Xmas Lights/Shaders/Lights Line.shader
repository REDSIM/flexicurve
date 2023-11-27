// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "RED_SIM/Lights Line"
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
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
		};

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

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 lerpResult6 = lerp( _WireColor , _BulbColor , i.vertexColor.r);
			o.Albedo = lerpResult6.rgb;
			float mulTime40 = _Time.y * _HueShiftSpeed;
			float mulTime9 = _Time.y * -_Speed;
			float2 appendResult31 = (float2(_Scale , 1.0));
			float2 uv_TexCoord8 = i.uv_texcoord * appendResult31;
			float2 appendResult26 = (float2(( mulTime9 + uv_TexCoord8.x ) , uv_TexCoord8.y));
			float3 hsvTorgb42 = RGBToHSV( ( tex2D( _GradientMap, appendResult26 ) * _Brightness * _Color * i.vertexColor.r ).rgb );
			float3 hsvTorgb43 = HSVToRGB( float3(( mulTime40 + hsvTorgb42.x ),hsvTorgb42.y,hsvTorgb42.z) );
			o.Emission = hsvTorgb43;
			float lerpResult16 = lerp( _WireSmoothness , _BulbSmoothness , i.vertexColor.r);
			o.Smoothness = lerpResult16;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17400
1927;29;1906;1004;2900.296;911.2853;2.271552;True;False
Node;AmplifyShaderEditor.RangedFloatNode;30;-2387.368,-64.96085;Inherit;False;Property;_Scale;Scale;9;0;Create;True;0;0;False;0;1;0.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-2264,-167;Inherit;False;Property;_Speed;Speed;6;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-2031.368,-57.96085;Inherit;False;FLOAT2;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;33;-1996.293,-164.4329;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;9;-1806,-159;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-1871,-77;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-1437.368,-83.96085;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;26;-1217.368,-44.96085;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-749,124.8282;Inherit;False;Property;_Brightness;Brightness;5;0;Create;True;0;0;False;0;1;21.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-859,-74;Inherit;True;Property;_GradientMap;Gradient Map;0;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;1c70bc65b3f819e4a90bcf0bd92d0af1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;34;-774.0709,200.8272;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;False;0;1,1,1,0;0.1691175,0.587424,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;2;-728.5266,387.4847;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-480,-59;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-813.5294,-235.3146;Inherit;False;Property;_HueShiftSpeed;Hue Shift Speed;2;0;Create;True;0;0;False;0;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;42;-296.196,-37.31461;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;40;-557.5294,-231.3146;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;4;-481,96;Inherit;False;Property;_WireColor;Wire Color;3;0;Create;True;0;0;False;0;0.004817439,0.1397059,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;13;-479.527,263.9146;Inherit;False;Property;_BulbColor;Bulb Color;4;0;Create;True;0;0;False;0;0.004817439,0.1397059,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;14;-244.527,423.9146;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-18.52939,-229.3146;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-487.7469,475.8212;Inherit;False;Property;_WireSmoothness;Wire Smoothness;7;0;Create;True;0;0;False;0;0.5;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;19;-510.7775,648.4734;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-497.121,551.9852;Inherit;False;Property;_BulbSmoothness;Bulb Smoothness;8;0;Create;True;0;0;False;0;0.5;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;43;154.804,-15.31461;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;16;-129.1905,503.9432;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;6;-129,288;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;517,58;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;RED_SIM/Lights Line;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;31;0;30;0
WireConnection;33;0;10;0
WireConnection;9;0;33;0
WireConnection;8;0;31;0
WireConnection;27;0;9;0
WireConnection;27;1;8;1
WireConnection;26;0;27;0
WireConnection;26;1;8;2
WireConnection;3;1;26;0
WireConnection;7;0;3;0
WireConnection;7;1;5;0
WireConnection;7;2;34;0
WireConnection;7;3;2;1
WireConnection;42;0;7;0
WireConnection;40;0;39;0
WireConnection;14;0;2;1
WireConnection;41;0;40;0
WireConnection;41;1;42;1
WireConnection;19;0;2;1
WireConnection;43;0;41;0
WireConnection;43;1;42;2
WireConnection;43;2;42;3
WireConnection;16;0;18;0
WireConnection;16;1;15;0
WireConnection;16;2;19;0
WireConnection;6;0;4;0
WireConnection;6;1;13;0
WireConnection;6;2;14;0
WireConnection;0;0;6;0
WireConnection;0;2;43;0
WireConnection;0;4;16;0
ASEEND*/
//CHKSM=6681FE5D91BEBA954593A0F44EBACDFECAFF8974