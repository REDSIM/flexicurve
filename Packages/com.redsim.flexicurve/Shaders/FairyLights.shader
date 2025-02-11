// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "RED_SIM/FairyLights"
{
	Properties
	{
		[Header(Wire)]_WireColor("Wire Color", Color) = (1,1,1,0)
		_Wire("Wire", 2D) = "white" {}
		[NoScaleOffset]_WireNormal("Wire Normal", 2D) = "bump" {}
		_WireNormalWeight("Wire Normal Weight", Float) = 1
		_WireSmoothness("Wire Smoothness", Range( 0 , 1)) = 0.5
		[Header(Elements)]_ElementColor("Element Color", Color) = (1,1,1,0)
		_Element("Element", 2D) = "white" {}
		[NoScaleOffset]_ElementMask("Element Mask", 2D) = "white" {}
		[NoScaleOffset]_ElementNormal("Element Normal", 2D) = "bump" {}
		_ElementNormalWeight1("Element Normal Weight", Float) = 1
		_ElementSmoothness("Element Smoothness", Range( 0 , 1)) = 0.5
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
		#include "UnityStandardUtils.cginc"
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

		uniform sampler2D _WireNormal;
		uniform sampler2D _Wire;
		uniform float4 _Wire_ST;
		uniform float _WireNormalWeight;
		uniform sampler2D _ElementNormal;
		uniform float _ElementNormalWeight1;
		uniform float4 _WireColor;
		uniform sampler2D _Element;
		uniform float4 _Element_ST;
		uniform float4 _ElementColor;
		uniform sampler2D _ElementMask;
		uniform float _HueShiftSpeed;
		uniform sampler2D _GradientMap;
		uniform float _Scale;
		uniform float _Speed;
		uniform float4 _Color;
		uniform float _Brightness;
		uniform float _WireSmoothness;
		uniform float _ElementSmoothness;


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
			float3 uvs_Wire = i.uv_texcoord;
			uvs_Wire.xy = i.uv_texcoord.xy * _Wire_ST.xy + _Wire_ST.zw;
			float ElementMask63 = sign( i.uv_texcoord.z );
			float3 lerpResult70 = lerp( UnpackScaleNormal( tex2D( _WireNormal, uvs_Wire.xy ), _WireNormalWeight ) , UnpackScaleNormal( tex2D( _ElementNormal, uvs_Wire.xy ), _ElementNormalWeight1 ) , ElementMask63);
			o.Normal = lerpResult70;
			float2 uv_Wire = i.uv_texcoord * _Wire_ST.xy + _Wire_ST.zw;
			float2 uv_Element = i.uv_texcoord * _Element_ST.xy + _Element_ST.zw;
			float4 lerpResult5 = lerp( ( tex2D( _Wire, uv_Wire ) * _WireColor ) , ( tex2D( _Element, uv_Element ) * _ElementColor ) , ElementMask63);
			o.Albedo = lerpResult5.rgb;
			float2 uv_ElementMask17 = i.uv_texcoord;
			float mulTime51 = _Time.y * _HueShiftSpeed;
			float mulTime47 = _Time.y * -_Speed;
			float temp_output_43_0 = ( ( i.uv_texcoord.z * _Scale ) + mulTime47 );
			float2 appendResult60 = (float2(temp_output_43_0 , temp_output_43_0));
			float3 hsvTorgb34 = RGBToHSV( ( tex2D( _GradientMap, appendResult60 ) * _Color * _Brightness ).rgb );
			float3 hsvTorgb54 = HSVToRGB( float3(( mulTime51 + hsvTorgb34.x ),hsvTorgb34.y,hsvTorgb34.z) );
			o.Emission = ( tex2D( _ElementMask, uv_ElementMask17 ).r * ( ElementMask63 * hsvTorgb54 ) );
			float lerpResult68 = lerp( _WireSmoothness , _ElementSmoothness , ElementMask63);
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
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-657.9257,276.3031;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RGBToHSVNode;34;-1483.123,668.4328;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.HSVToRGBNode;54;-1132.206,691.6579;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-888.3143,501.4113;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;51;-1456.87,579.7599;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1755.132,570.8112;Inherit;False;Property;_HueShiftSpeed;Hue Shift Speed;16;0;Create;True;0;0;0;False;0;False;0.3247432;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-1256.224,668.2924;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1666.927,668.6425;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;50;-2045.126,653.6423;Inherit;True;Property;_GradientMap;Gradient Map;12;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-2349.496,678.4018;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;60;-2205.1,677.4199;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-2510.326,562.9072;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;48;-2702.209,702.8002;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;47;-2548.948,703.77;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-2738.262,430.7856;Inherit;False;0;-1;3;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;46;-2697.138,585.4774;Inherit;False;Property;_Scale;Scale;13;0;Create;False;0;0;0;False;0;False;1;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-2857.523,702.6142;Inherit;False;Property;_Speed;Speed;15;0;Create;False;0;0;0;False;0;False;2;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SignOpNode;6;-1284.513,500.1919;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;444.7998,-142.4;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;RED_SIM/FairyLights;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.LerpOp;68;249.8418,247.1889;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;5.841797,356.7889;Inherit;False;63;ElementMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;32;-1975.398,835.6694;Inherit;False;Property;_Color;Color;11;1;[Header];Create;False;1;Light Effects;0;0;False;0;False;1,1,1,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;31;-1908.727,1014.07;Inherit;False;Property;_Brightness;Brightness;14;0;Create;True;0;0;0;False;0;False;1;26.77;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;70;-200.5439,-153.5919;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;73;-790.9447,-347.1913;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;71;-444.2124,103.4086;Inherit;False;63;ElementMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-1145.618,500.1977;Inherit;False;ElementMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;17;-992.0209,253.5652;Inherit;True;Property;_ElementMask;Element Mask;7;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;4;None;1dd51959867131f4a82e25721a9f8ccb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;67;-81.35815,269.5889;Inherit;False;Property;_ElementSmoothness;Element Smoothness;10;0;Create;False;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-81.43253,192.7134;Inherit;False;Property;_WireSmoothness;Wire Smoothness;4;0;Create;False;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;69;-547.9142,-276.0209;Inherit;True;Property;_WireNormal;Wire Normal;2;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;a0ff6979548b7e34f86ac2287df8dfe4;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;75;-538.5873,-91.7196;Inherit;True;Property;_ElementNormal;Element Normal;8;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;72;-796.6875,-228.445;Inherit;False;Property;_WireNormalWeight;Wire Normal Weight;3;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-808.1873,-41.31958;Inherit;False;Property;_ElementNormalWeight1;Element Normal Weight;9;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;5;-218.1199,-866.0942;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-458.1366,-870.4627;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-483.7368,-683.2629;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-1006.86,-870.0897;Inherit;True;Property;_Wire;Wire;1;0;Create;True;0;0;0;False;0;False;-1;None;eb53438b32ff40745a4297fba52b1d70;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;19;-725.3367,-809.663;Inherit;False;Property;_WireColor;Wire Color;0;1;[Header];Create;True;1;Wire;0;0;False;0;False;1,1,1,0;0.4490563,0.4490563,0.4490563,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;65;-480.5129,-569.8977;Inherit;False;63;ElementMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-1006.853,-684.2895;Inherit;True;Property;_Element;Element;6;0;Create;True;0;0;0;False;0;False;-1;None;750b1bd7ba8bd28489650de6d0a95cc5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;21;-719.9072,-619.2939;Inherit;False;Property;_ElementColor;Element Color;5;1;[Header];Create;True;1;Elements;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
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
WireConnection;0;0;5;0
WireConnection;0;1;70;0
WireConnection;0;2;18;0
WireConnection;0;4;68;0
WireConnection;68;0;38;0
WireConnection;68;1;67;0
WireConnection;68;2;66;0
WireConnection;70;0;69;0
WireConnection;70;1;75;0
WireConnection;70;2;71;0
WireConnection;63;0;6;0
WireConnection;69;1;73;0
WireConnection;69;5;72;0
WireConnection;75;1;73;0
WireConnection;75;5;76;0
WireConnection;5;0;20;0
WireConnection;5;1;22;0
WireConnection;5;2;65;0
WireConnection;20;0;1;0
WireConnection;20;1;19;0
WireConnection;22;0;4;0
WireConnection;22;1;21;0
ASEEND*/
//CHKSM=176CC25EECD66A4C43DAC5CD559B3D827ADA2146