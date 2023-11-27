// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "RED_SIM/Lights Flipbook"
{
	Properties
	{
		[NoScaleOffset]_FlipbookTexture("Flipbook Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,0)
		_HueShiftSpeed("Hue Shift Speed", Range( 0 , 2)) = 0
		_WireColor("Wire Color", Color) = (0.004817439,0.1397059,0,0)
		_BulbColor("Bulb Color", Color) = (0.004817439,0.1397059,0,0)
		_Brightness("Brightness", Float) = 1
		_Speed("Speed", Float) = 1
		_WireSmoothness("Wire Smoothness", Range( 0 , 1)) = 0.5
		_BulbSmoothness("Bulb Smoothness", Range( 0 , 1)) = 0.5
		_Rows("Rows", Int) = 1
		_Columns("Columns", Int) = 1
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
		uniform sampler2D _FlipbookTexture;
		uniform int _Columns;
		uniform int _Rows;
		uniform float _Speed;
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
			float mulTime45 = _Time.y * _HueShiftSpeed;
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles34 = (float)_Columns * (float)_Rows;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset34 = 1.0f / (float)_Columns;
			float fbrowsoffset34 = 1.0f / (float)_Rows;
			// Speed of animation
			float fbspeed34 = _Time.y * _Speed;
			// UV Tiling (col and row offset)
			float2 fbtiling34 = float2(fbcolsoffset34, fbrowsoffset34);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex34 = round( fmod( fbspeed34 + 0.0, fbtotaltiles34) );
			fbcurrenttileindex34 += ( fbcurrenttileindex34 < 0) ? fbtotaltiles34 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox34 = round ( fmod ( fbcurrenttileindex34, (float)_Columns ) );
			// Multiply Offset X by coloffset
			float fboffsetx34 = fblinearindextox34 * fbcolsoffset34;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy34 = round( fmod( ( fbcurrenttileindex34 - fblinearindextox34 ) / (float)_Columns, (float)_Rows ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy34 = (int)((float)_Rows-1) - fblinearindextoy34;
			// Multiply Offset Y by rowoffset
			float fboffsety34 = fblinearindextoy34 * fbrowsoffset34;
			// UV Offset
			float2 fboffset34 = float2(fboffsetx34, fboffsety34);
			// Flipbook UV
			half2 fbuv34 = i.uv_texcoord * fbtiling34 + fboffset34;
			// *** END Flipbook UV Animation vars ***
			float3 hsvTorgb42 = RGBToHSV( ( tex2D( _FlipbookTexture, fbuv34 ) * _Brightness * _Color * i.vertexColor.r ).rgb );
			float3 hsvTorgb43 = HSVToRGB( float3(( mulTime45 + hsvTorgb42.x ),hsvTorgb42.y,hsvTorgb42.z) );
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
1927;29;1906;1004;1575.995;526.0693;1.3;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;9;-1866.6,97.09999;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;38;-1924.168,-153.2349;Inherit;False;Property;_Columns;Columns;10;0;Create;True;0;0;False;0;1;0;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;39;-1927.168,-83.23492;Inherit;False;Property;_Rows;Rows;9;0;Create;True;0;0;False;0;1;0;0;1;INT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-1876.139,-291.563;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;10;-1957.3,12.50001;Inherit;False;Property;_Speed;Speed;6;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;34;-1592.74,-97.86232;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.VertexColorNode;2;-728.5266,387.4847;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-981.7999,-125.8;Inherit;True;Property;_FlipbookTexture;Flipbook Texture;0;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-842,126.8282;Inherit;False;Property;_Brightness;Brightness;5;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;41;-835.4773,206.8915;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;46;-465.4974,-143.8158;Inherit;False;Property;_HueShiftSpeed;Hue Shift Speed;2;0;Create;True;0;0;False;0;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-476,-43;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RGBToHSVNode;42;-243.7654,-41.5769;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;45;-209.4974,-139.8158;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;13;-479.527,263.9146;Inherit;False;Property;_BulbColor;Bulb Color;4;0;Create;True;0;0;False;0;0.004817439,0.1397059,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;44;38.50256,-45.81583;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-487.7469,475.8212;Inherit;False;Property;_WireSmoothness;Wire Smoothness;7;0;Create;True;0;0;False;0;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;14;-244.527,423.9146;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;19;-510.7775,648.4734;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;4;-481,96;Inherit;False;Property;_WireColor;Wire Color;3;0;Create;True;0;0;False;0;0.004817439,0.1397059,0,0;0.004817439,0.1397059,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-497.121,551.9852;Inherit;False;Property;_BulbSmoothness;Bulb Smoothness;8;0;Create;True;0;0;False;0;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;43;229.5026,-20.81583;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;16;-129.1905,503.9432;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;6;-129,288;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;656,-88;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;RED_SIM/Lights Flipbook;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;34;0;35;0
WireConnection;34;1;38;0
WireConnection;34;2;39;0
WireConnection;34;3;10;0
WireConnection;34;5;9;0
WireConnection;3;1;34;0
WireConnection;7;0;3;0
WireConnection;7;1;5;0
WireConnection;7;2;41;0
WireConnection;7;3;2;1
WireConnection;42;0;7;0
WireConnection;45;0;46;0
WireConnection;44;0;45;0
WireConnection;44;1;42;1
WireConnection;14;0;2;1
WireConnection;19;0;2;1
WireConnection;43;0;44;0
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
//CHKSM=DAAF46BE300FB5264568CDAE43B02F6FC527C9DE