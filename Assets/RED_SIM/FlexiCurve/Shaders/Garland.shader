// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "RED_SIM/Garland"
{
	Properties
	{
		[Header(Wire)]_WireColor("Wire Color", Color) = (1,1,1,0)
		_Wire("Wire", 2D) = "white" {}
		_WireSmoothness("Wire Smoothness", Range( 0 , 1)) = 0.5
		[Header(Lamp)]_LampColor("Lamp Color", Color) = (1,1,1,0)
		_Lamp("Lamp", 2D) = "white" {}
		[NoScaleOffset]_LampMask("Lamp Mask", 2D) = "white" {}
		_LampSmoothness("Lamp Smoothness", Range( 0 , 1)) = 0.5
		[Header(Light Effects)]_Color("Color", Color) = (1,1,1,1)
		[NoScaleOffset]_GradientMap("Gradient Map", 2D) = "white" {}
		_Scale("Scale", Float) = 1
		_Brightness("Brightness", Float) = 1
		_Speed("Speed", Float) = 2
		_HueShiftSpeed("Hue Shift Speed", Range( 0 , 2)) = 0.3247432
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Forward Rendering Options)]
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
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
		uniform float _HueShiftSpeed;
		uniform sampler2D _GradientMap;
		uniform float _Scale;
		uniform float _Speed;
		uniform float4 _Color;
		uniform float _Brightness;
		uniform float _WireSmoothness;
		uniform float _LampSmoothness;


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
			float2 uv_Wire = i.uv_texcoord * _Wire_ST.xy + _Wire_ST.zw;
			float2 uv_Lamp = i.uv_texcoord * _Lamp_ST.xy + _Lamp_ST.zw;
			float LampMask63 = sign( i.uv_texcoord.z );
			float4 lerpResult5 = lerp( ( tex2D( _Wire, uv_Wire ) * _WireColor ) , ( tex2D( _Lamp, uv_Lamp ) * _LampColor ) , LampMask63);
			o.Albedo = lerpResult5.rgb;
			float2 uv_LampMask17 = i.uv_texcoord;
			float mulTime51 = _Time.y * _HueShiftSpeed;
			float mulTime47 = _Time.y * -_Speed;
			float temp_output_43_0 = ( ( i.uv_texcoord.z * _Scale ) + mulTime47 );
			float2 appendResult60 = (float2(temp_output_43_0 , temp_output_43_0));
			float3 hsvTorgb34 = RGBToHSV( ( tex2D( _GradientMap, appendResult60 ) * _Color * _Brightness ).rgb );
			float3 hsvTorgb54 = HSVToRGB( float3(( mulTime51 + hsvTorgb34.x ),hsvTorgb34.y,hsvTorgb34.z) );
			o.Emission = ( tex2D( _LampMask, uv_LampMask17 ).r * ( LampMask63 * hsvTorgb54 ) );
			float lerpResult68 = lerp( _WireSmoothness , _LampSmoothness , LampMask63);
			o.Smoothness = lerpResult68;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.LerpOp;5;-104.6371,-147.5044;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-443.2764,-151.8731;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-468.8765,35.32684;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-657.9257,276.3031;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RGBToHSVNode;34;-1483.123,668.4328;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.HSVToRGBNode;54;-1132.206,691.6579;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-888.3143,501.4113;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;51;-1456.87,579.7599;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1755.132,570.8112;Inherit;False;Property;_HueShiftSpeed;Hue Shift Speed;12;0;Create;True;0;0;0;False;0;False;0.3247432;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-1256.224,668.2924;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1666.927,668.6425;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;50;-2045.126,653.6423;Inherit;True;Property;_GradientMap;Gradient Map;8;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;3a8ff7a1660f65044906dd48a1154ddd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-2349.496,678.4018;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;60;-2205.1,677.4199;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-2510.326,562.9072;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;48;-2702.209,702.8002;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;47;-2548.948,703.77;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-2738.262,430.7856;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;46;-2697.138,585.4774;Inherit;False;Property;_Scale;Scale;9;0;Create;False;0;0;0;False;0;False;1;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-2857.523,702.6142;Inherit;False;Property;_Speed;Speed;11;0;Create;False;0;0;0;False;0;False;2;0.37;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;6;-1284.513,500.1919;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-1145.618,500.1977;Inherit;False;LampMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;444.7998,-142.4;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;RED_SIM/Garland;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-78.23245,192.7134;Inherit;False;Property;_WireSmoothness;Wire Smoothness;2;0;Create;False;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-81.35815,269.5889;Inherit;False;Property;_LampSmoothness;Lamp Smoothness;6;0;Create;False;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;68;249.8418,247.1889;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;5.841797,356.7889;Inherit;False;63;LampMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;19;-710.4766,-91.07318;Inherit;False;Property;_WireColor;Wire Color;0;1;[Header];Create;True;1;Wire;0;0;False;0;False;1,1,1,0;0.4490564,0.4490564,0.4490564,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;65;-467.2527,135.8921;Inherit;False;63;LampMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;21;-705.0472,99.29581;Inherit;False;Property;_LampColor;Lamp Color;3;1;[Header];Create;True;1;Lamp;0;0;False;0;False;1,1,1,0;0.2603772,0.2603772,0.2603772,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;32;-1975.398,835.6694;Inherit;False;Property;_Color;Color;7;1;[Header];Create;False;1;Light Effects;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;17;-992.0209,253.5652;Inherit;True;Property;_LampMask;Lamp Mask;5;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;4;None;1dd51959867131f4a82e25721a9f8ccb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-991.9921,34.30023;Inherit;True;Property;_Lamp;Lamp;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-991.9999,-151.5;Inherit;True;Property;_Wire;Wire;1;0;Create;True;0;0;0;False;0;False;-1;None;6ab3bf657b68d194fabdd422fc40db7c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;31;-1908.727,1014.07;Inherit;False;Property;_Brightness;Brightness;10;0;Create;True;0;0;0;False;0;False;1;26.77;0;0;0;1;FLOAT;0
WireConnection;5;0;20;0
WireConnection;5;1;22;0
WireConnection;5;2;65;0
WireConnection;20;0;1;0
WireConnection;20;1;19;0
WireConnection;22;0;4;0
WireConnection;22;1;21;0
WireConnection;18;0;17;1
WireConnection;18;1;59;0
WireConnection;34;0;41;0
WireConnection;54;0;53;0
WireConnection;54;1;34;2
WireConnection;54;2;34;3
WireConnection;59;0;63;0
WireConnection;59;1;54;0
WireConnection;51;0;52;0
WireConnection;53;0;51;0
WireConnection;53;1;34;1
WireConnection;41;0;50;0
WireConnection;41;1;32;0
WireConnection;41;2;31;0
WireConnection;50;1;60;0
WireConnection;43;0;13;0
WireConnection;43;1;47;0
WireConnection;60;0;43;0
WireConnection;60;1;43;0
WireConnection;13;0;2;3
WireConnection;13;1;46;0
WireConnection;48;0;49;0
WireConnection;47;0;48;0
WireConnection;6;0;2;3
WireConnection;63;0;6;0
WireConnection;0;0;5;0
WireConnection;0;2;18;0
WireConnection;0;4;68;0
WireConnection;68;0;38;0
WireConnection;68;1;67;0
WireConnection;68;2;66;0
ASEEND*/
//CHKSM=708E2AD7C1DEF11A886B91B38F76A11F5582F853