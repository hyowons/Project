// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Text"
{
	Properties
	{
		_MainTex ("Alpha (A)", 2D) = "white" {}
	}

	SubShader
	{
		LOD 200

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Offset -1, -1
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				struct appdata_t
				{
					float4 vertex : POSITION;
					half4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					half3 normal : NORMAL;
				};

				struct v2f
				{
					float4 vertex : POSITION;
					half4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					half3 addEffect : TEXCOORD1; // x: gray,  y: brightness
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;

				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.texcoord = v.texcoord;
					o.color = v.color;
					
					o.addEffect = v.normal;
					return o;
				}

				half4 frag (v2f i) : COLOR
				{
//					half4 col = i.color;
//					col.a *= tex2D(_MainTex, i.texcoord).a;
//					return col;

					half4 col = i.color;
					col.a *= tex2D(_MainTex, i.texcoord).a;
					
					if( 1.0 <= i.addEffect.x ) // gray
					{
						float grayscale = dot(col.rgb, float3(0.3, 0.59, 0.11));
						col.rgb = grayscale;
					}
					
					col.rgb *= i.addEffect.y; // brightness
									
					return col;
				}
			ENDCG
		}
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
		}
		
		Lighting Off
		Cull Off
		ZTest Always
		ZWrite Off
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha
		
		BindChannels
		{
			Bind "Color", color
			Bind "Vertex", vertex
			Bind "TexCoord", texcoord
		}
		
		Pass
		{
			SetTexture [_MainTex]
			{ 
				combine primary, texture
			}
		}
	}
}
