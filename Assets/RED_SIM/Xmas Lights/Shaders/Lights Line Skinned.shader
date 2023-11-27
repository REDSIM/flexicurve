// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "RED_SIM/Lights Line Skinned"
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
		_TargetStrandLength("Target Strand Length", Float) = 8
		_Droopiness("Droopiness", Float) = 0.5
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 vertexToFrag95;
		};

		uniform float _TargetStrandLength;
		uniform float _Droopiness;
		uniform float4 _WireColor;
		uniform float4 _BulbColor;
		uniform float _Speed;
		uniform float _Scale;
		uniform float _HueShiftSpeed;
		uniform sampler2D _GradientMap;
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

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 leftSide50 = v.texcoord3.xyz;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 rightSide52 = ase_vertex3Pos;
			float strandLength55 = length( ( leftSide50 - rightSide52 ) );
			float temp_output_103_0 = ( v.texcoord2.w * max( ( _TargetStrandLength / strandLength55 ) , 1.0 ) );
			float unsaturatedWeight108 = temp_output_103_0;
			float weightPaint101 = saturate( temp_output_103_0 );
			float temp_output_131_0 = ( weightPaint101 - 0.5 );
			float3 appendResult117 = (float3(v.texcoord2.x , ( v.texcoord2.y - ( ( sqrt( ( 1.0 - ( 3.0 * temp_output_131_0 * temp_output_131_0 ) ) ) - sqrt( 0.25 ) ) * log( ( strandLength55 + 1.0 ) ) * _Droopiness ) ) , v.texcoord2.z));
			float3 lerpResult113 = lerp( leftSide50 , rightSide52 , weightPaint101);
			v.vertex.xyz = (( unsaturatedWeight108 < 1.03125 ) ? ( appendResult117 + lerpResult113 ) :  ase_vertex3Pos );
			float mulTime9 = _Time.y * -_Speed;
			float3 appendResult26 = (float3(( mulTime9 + 0.0 + ( _Scale * v.texcoord.xyz.x ) ) , v.texcoord.xyz.y , v.texcoord.xyz.z));
			o.vertexToFrag95 = appendResult26;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float formerlyVertexColor99 = (i.vertexToFrag95).z;
			float4 lerpResult6 = lerp( _WireColor , _BulbColor , formerlyVertexColor99);
			o.Albedo = lerpResult6.rgb;
			float mulTime40 = _Time.y * _HueShiftSpeed;
			float3 hsvTorgb42 = RGBToHSV( ( tex2D( _GradientMap, i.vertexToFrag95.xy ) * _Brightness * _Color * formerlyVertexColor99 ).rgb );
			float3 hsvTorgb43 = HSVToRGB( float3(( mulTime40 + hsvTorgb42.x ),hsvTorgb42.y,hsvTorgb42.z) );
			o.Emission = hsvTorgb43;
			float lerpResult16 = lerp( _WireSmoothness , _BulbSmoothness , formerlyVertexColor99);
			o.Smoothness = lerpResult16;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17500
128;556;2086;1422;2787.363;550.5991;1.269061;True;True
Node;AmplifyShaderEditor.TexCoordVertexDataNode;49;-1907.347,1193.147;Inherit;False;3;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;51;-1899.083,1349.677;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-1693.082,1193.677;Inherit;False;leftSide;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-1697.082,1293.677;Inherit;False;rightSide;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;53;-1465.082,1280.677;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;54;-1310.082,1320.677;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;-1179.019,1334.879;Inherit;False;strandLength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;-1907.644,907.6876;Inherit;False;55;strandLength;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-1942.97,818.7335;Inherit;False;Property;_TargetStrandLength;Target Strand Length;10;0;Create;True;0;0;False;0;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;104;-1657.276,840.7681;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;44;-1621.323,669.3953;Inherit;False;2;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;102;-1516.104,857.8152;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-1373.463,808.6849;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;106;-1249.12,945.7249;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-2264,-167;Inherit;False;Property;_Speed;Speed;6;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-1092.54,961.1062;Inherit;False;weightPaint;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2000.575,-55.65219;Inherit;False;Property;_Scale;Scale;9;0;Create;True;0;0;False;0;1;0.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;132;-2129.503,490.0872;Inherit;False;101;weightPaint;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-2107.108,567.9244;Inherit;False;Constant;_Float0;Float 0;12;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;58;-2053.652,49.42191;Inherit;False;0;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;33;-1996.293,-164.4329;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;131;-1950.048,499.1537;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;9;-1806,-159;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-1808.88,3.156219;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-1790.427,450.5734;Inherit;False;3;3;0;FLOAT;3;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-1574.423,-85.40354;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;26;-1442.427,-42.07547;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;-1735.459,575.5444;Inherit;False;55;strandLength;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;129;-1623.865,442.4767;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;95;-1313.115,-57.60589;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SqrtOpNode;127;-1482.75,511.8773;Inherit;False;1;0;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;125;-1532.488,578.9645;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;128;-1478.123,430.9445;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-1422.082,648.1867;Inherit;False;Property;_Droopiness;Droopiness;11;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;126;-1348.576,488.7438;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LogOpNode;122;-1374.127,581.1262;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;97;-1049.051,52.04828;Inherit;False;FLOAT;2;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-859,-74;Inherit;True;Property;_GradientMap;Gradient Map;0;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;1c70bc65b3f819e4a90bcf0bd92d0af1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-749,124.8282;Inherit;False;Property;_Brightness;Brightness;5;0;Create;True;0;0;False;0;1;21.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-1225.735,603.5755;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;-774.0709,200.8272;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;False;0;1,1,1,0;0.1691175,0.587424,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-804.0587,391.9995;Inherit;False;formerlyVertexColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-480,-59;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-813.5294,-235.3146;Inherit;False;Property;_HueShiftSpeed;Hue Shift Speed;2;0;Create;True;0;0;False;0;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-1089.347,820.7255;Inherit;False;50;leftSide;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;-1082.118,897.4883;Inherit;False;52;rightSide;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;118;-1060.314,683.0158;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;117;-907.554,666.3647;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;113;-884.0071,857.6324;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RGBToHSVNode;42;-296.196,-37.31461;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;40;-557.5294,-231.3146;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;108;-1234.997,776.0527;Inherit;False;unsaturatedWeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;19;-510.7775,648.4734;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;4;-481,96;Inherit;False;Property;_WireColor;Wire Color;3;0;Create;True;0;0;False;0;0.004817439,0.1397059,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;14;-244.527,423.9146;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;77.58229,598.6305;Inherit;False;108;unsaturatedWeight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;47;48.18255,714.0087;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;13;-479.527,263.9146;Inherit;False;Property;_BulbColor;Bulb Color;4;0;Create;True;0;0;False;0;0.004817439,0.1397059,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-497.121,551.9852;Inherit;False;Property;_BulbSmoothness;Bulb Smoothness;8;0;Create;True;0;0;False;0;0.5;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-487.7469,475.8212;Inherit;False;Property;_WireSmoothness;Wire Smoothness;7;0;Create;True;0;0;False;0;0.5;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-18.52939,-229.3146;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;112;-730.9766,675.3856;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;16;-129.1905,503.9432;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;65;-1455.309,1150.302;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;61;-1303.829,1122.444;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCCompareLower;109;324.8125,600.4893;Inherit;False;4;0;FLOAT;0;False;1;FLOAT;1.03125;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-1790.319,-76.57848;Inherit;False;83;timeOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;6;-129,288;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.HSVToRGBNode;43;154.804,-15.31461;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;74;-377.9522,1141.236;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomExpressionNode;133;-201.778,1151.867;Inherit;False;abs(dot(frac(sin(dot(uv ,float2(12.9898,78.233)*2.0)) * 43758.5453), 0.5));1;False;1;True;uv;FLOAT2;0,0;In;;Float;False;Sin+Frac Noise;True;False;0;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;83;-11.3244,1158.552;Inherit;False;timeOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;75;-506.3034,1106.046;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;63;-1099.901,1124.077;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-940.724,1127.615;Inherit;False;worldPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;73;-742.2068,1123.647;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;517,58;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;RED_SIM/Lights Line Skinned;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;50;0;49;0
WireConnection;52;0;51;0
WireConnection;53;0;50;0
WireConnection;53;1;52;0
WireConnection;54;0;53;0
WireConnection;55;0;54;0
WireConnection;104;0;105;0
WireConnection;104;1;120;0
WireConnection;102;0;104;0
WireConnection;103;0;44;4
WireConnection;103;1;102;0
WireConnection;106;0;103;0
WireConnection;101;0;106;0
WireConnection;33;0;10;0
WireConnection;131;0;132;0
WireConnection;131;1;134;0
WireConnection;9;0;33;0
WireConnection;94;0;30;0
WireConnection;94;1;58;1
WireConnection;130;1;131;0
WireConnection;130;2;131;0
WireConnection;27;0;9;0
WireConnection;27;2;94;0
WireConnection;26;0;27;0
WireConnection;26;1;58;2
WireConnection;26;2;58;3
WireConnection;129;1;130;0
WireConnection;95;0;26;0
WireConnection;125;0;124;0
WireConnection;128;0;129;0
WireConnection;126;0;128;0
WireConnection;126;1;127;0
WireConnection;122;0;125;0
WireConnection;97;0;95;0
WireConnection;3;1;95;0
WireConnection;121;0;126;0
WireConnection;121;1;122;0
WireConnection;121;2;119;0
WireConnection;99;0;97;0
WireConnection;7;0;3;0
WireConnection;7;1;5;0
WireConnection;7;2;34;0
WireConnection;7;3;99;0
WireConnection;118;0;44;2
WireConnection;118;1;121;0
WireConnection;117;0;44;1
WireConnection;117;1;118;0
WireConnection;117;2;44;3
WireConnection;113;0;114;0
WireConnection;113;1;115;0
WireConnection;113;2;101;0
WireConnection;42;0;7;0
WireConnection;40;0;39;0
WireConnection;108;0;103;0
WireConnection;19;0;99;0
WireConnection;14;0;99;0
WireConnection;41;0;40;0
WireConnection;41;1;42;1
WireConnection;112;0;117;0
WireConnection;112;1;113;0
WireConnection;16;0;18;0
WireConnection;16;1;15;0
WireConnection;16;2;19;0
WireConnection;65;0;50;0
WireConnection;61;0;65;0
WireConnection;109;0;110;0
WireConnection;109;2;112;0
WireConnection;109;3;47;0
WireConnection;6;0;4;0
WireConnection;6;1;13;0
WireConnection;6;2;14;0
WireConnection;43;0;41;0
WireConnection;43;1;42;2
WireConnection;43;2;42;3
WireConnection;74;0;75;0
WireConnection;74;1;73;1
WireConnection;133;0;74;0
WireConnection;83;0;133;0
WireConnection;75;0;73;0
WireConnection;75;1;73;2
WireConnection;63;0;61;0
WireConnection;64;0;63;0
WireConnection;73;0;64;0
WireConnection;0;0;6;0
WireConnection;0;2;43;0
WireConnection;0;4;16;0
WireConnection;0;11;109;0
ASEEND*/
//CHKSM=709B319728FCDF92F36B7194697BA365727A99AC