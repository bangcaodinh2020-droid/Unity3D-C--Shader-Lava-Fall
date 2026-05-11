Shader "Custom/RockSurface"
{
    Properties
    {
        _MainTex ("Noise Texture", 2D) = "white" {}

        _BaseColor ("Base Color", Color) = (0.25,0.25,0.25,1)
        _DarkColor ("Dark Color", Color) = (0.05,0.05,0.05,1)

        _NoiseScale ("Noise Scale", Float) = 2.0
        _DetailStrength ("Detail Strength", Float) = 0.3

        _CrackThreshold ("Crack Threshold", Range(0,1)) = 0.6
        _CrackSharpness ("Crack Sharpness", Range(0.01,0.5)) = 0.1

        _Roughness ("Roughness", Range(0,1)) = 0.8
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _BaseColor;
            fixed4 _DarkColor;

            float _NoiseScale;
            float _DetailStrength;

            float _CrackThreshold;
            float _CrackSharpness;

            float _Roughness;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            //--------------------------------
            // NOISE FUNCTION
            //--------------------------------

            float hash(float2 p)
            {
                return frac(
                    sin(dot(p, float2(127.1,311.7)))
                    * 43758.5453
                );
            }

            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);

                float a = hash(i);
                float b = hash(i + float2(1,0));
                float c = hash(i + float2(0,1));
                float d = hash(i + float2(1,1));

                float2 u = f * f * (3.0 - 2.0 * f);

                return lerp(
                    lerp(a,b,u.x),
                    lerp(c,d,u.x),
                    u.y
                );
            }

            

            //--------------------------------
            // VERTEX
            //--------------------------------

            v2f vert (appdata v)
            {
                v2f o;

                float3 worldPos =
                    mul(unity_ObjectToWorld, v.vertex).xyz;

                // float n =
                //     noise(worldPos.xz * _NoiseScale);
                float3 objPos = v.vertex.xyz;
                float n = noise(objPos.xz * _NoiseScale);

                // fake rock bump
                worldPos += v.normal * n * _DetailStrength;

                o.worldPos = worldPos;

                o.pos =
                    UnityWorldToClipPos(worldPos);

                o.worldNormal =
                    UnityObjectToWorldNormal(v.normal);

                o.uv =
                    TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            //--------------------------------
            // FRAGMENT
            //--------------------------------

            fixed4 frag (v2f i) : SV_Target
            {
                //--------------------------------
                // BASE NOISE
                //--------------------------------

                float n =
                    noise(i.worldPos.xz * _NoiseScale);

                //--------------------------------
                // CRACKS
                //--------------------------------

                float cracks =
                    smoothstep(
                        _CrackThreshold,
                        _CrackThreshold + _CrackSharpness,
                        n
                    );

                //--------------------------------
                // COLOR VARIATION
                //--------------------------------

                fixed3 color =
                    lerp(
                        _DarkColor.rgb,
                        _BaseColor.rgb,
                        n
                    );

                color *= (1.0 - cracks);

                //--------------------------------
                // LIGHTING (Lambert)
                //--------------------------------

                float3 lightDir =
                    normalize(_WorldSpaceLightPos0.xyz);

                float NdotL =
                    saturate(dot(
                        normalize(i.worldNormal),
                        lightDir
                    ));

                float lighting =
                    lerp(0.3, 1.0, NdotL);

                color *= lighting;

                //--------------------------------
                // FINAL
                //--------------------------------

                return fixed4(color,1);
            }

            ENDCG
        }
    }
}