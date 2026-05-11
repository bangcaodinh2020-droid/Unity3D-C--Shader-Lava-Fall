Shader "Custom/LavaVolcanoClassic"
{
    Properties
    {
        _MainTex ("Noise Texture", 2D) = "white" {}

        _RockColor ("Rock Color", Color) = (0.05,0.05,0.05,1)
        _LavaColor ("Lava Color", Color) = (1,0.3,0,1)

        _EmissionStrength ("Emission Strength", Float) = 5

        _CrackThreshold ("Crack Threshold", Range(0,1)) = 0.6
        _CrackSmoothness ("Crack Smoothness", Range(0.001,0.5)) = 0.1

        _FlowX ("Flow X", Float) = 0.1
        _FlowY ("Flow Y", Float) = 0.02

        _Distortion ("Distortion", Float) = 0.03

        _PulseSpeed ("Pulse Speed", Float) = 2.0
        _PulseStrength ("Pulse Strength", Float) = 1.5
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        LOD 200

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;

            float4 _MainTex_ST;

            fixed4 _RockColor;
            fixed4 _LavaColor;

            float _EmissionStrength;

            float _CrackThreshold;
            float _CrackSmoothness;

            float _FlowX;
            float _FlowY;

            float _Distortion;

            float _PulseSpeed;
            float _PulseStrength;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normalDir : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normalDir = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //--------------------------------
                // FLOW
                //--------------------------------

                float2 flow =
                    float2(_FlowX, _FlowY)
                    * _Time.y;

                float2 uv = i.uv + flow;

                //--------------------------------
                // DISTORTION
                //--------------------------------

                float distortionNoise =
                    tex2D(_MainTex, uv * 2.0).r;

                uv +=
                    (distortionNoise - 0.5)
                    * _Distortion;

                //--------------------------------
                // MAIN NOISE
                //--------------------------------

                float noise =
                    tex2D(_MainTex, uv).r;

                //--------------------------------
                // CRACK MASK
                //--------------------------------

                float cracks =
                    smoothstep(
                        _CrackThreshold,
                        _CrackThreshold + _CrackSmoothness,
                        noise
                    );

                //--------------------------------
                // BASE COLOR
                //--------------------------------

                fixed3 baseColor =
                    lerp(
                        _RockColor.rgb,
                        _LavaColor.rgb,
                        cracks
                    );

                //--------------------------------
                // PULSE
                //--------------------------------

                float pulse =
                    sin(_Time.y * _PulseSpeed)
                    * 0.5 + 0.5;

                pulse *= _PulseStrength;

                //--------------------------------
                // EMISSION
                //--------------------------------

                fixed3 emission =
                    _LavaColor.rgb
                    * cracks
                    * (_EmissionStrength + pulse);

                //--------------------------------
                // SIMPLE LIGHTING
                //--------------------------------

                float3 normal =
                    normalize(i.normalDir);

                float3 lightDir =
                    normalize(_WorldSpaceLightPos0.xyz);

                float NdotL =
                    saturate(dot(normal, lightDir));

                fixed3 finalColor =
                    baseColor * (0.2 + NdotL)
                    + emission;

                return fixed4(finalColor, 1);
            }

            ENDCG
        }
    }
}