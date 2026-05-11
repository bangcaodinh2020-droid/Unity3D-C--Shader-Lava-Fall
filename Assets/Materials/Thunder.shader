Shader "Custom/ThunderRain"
{
    Properties
    {
        _MainTex ("Noise Texture", 2D) = "white" {}

        _SkyColor ("Sky Color", Color) =
        (0.02,0.02,0.08,1)

        _CloudColor ("Cloud Color", Color) =
        (0.15,0.15,0.2,1)

        _LightningColor ("Lightning Color", Color) =
        (0.7,0.9,1,1)

        _RainColor ("Rain Color", Color) =
        (0.7,0.8,1,1)

        _CloudSpeed ("Cloud Speed", Float) = 0.02

        _RainSpeed ("Rain Speed", Float) = 2.5

        _RainDensity ("Rain Density", Range(1,200)) = 80

        _LightningIntensity
        ("Lightning Intensity", Float) = 3

        _LightningFrequency
        ("Lightning Frequency", Float) = 1.5

        _CloudScale ("Cloud Scale", Float) = 2

        _RainWidth ("Rain Width", Float) = 0.02
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;

            float4 _MainTex_ST;

            fixed4 _SkyColor;
            fixed4 _CloudColor;
            fixed4 _LightningColor;
            fixed4 _RainColor;

            float _CloudSpeed;
            float _RainSpeed;
            float _RainDensity;

            float _LightningIntensity;
            float _LightningFrequency;

            float _CloudScale;
            float _RainWidth;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            //--------------------------------
            // RANDOM
            //--------------------------------

            float rand(float2 co)
            {
                return frac(
                    sin(dot(co.xy,
                    float2(12.9898,78.233)))
                    * 43758.5453
                );
            }

            //--------------------------------
            // VERTEX
            //--------------------------------

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex =
                    UnityObjectToClipPos(v.vertex);

                o.uv =
                    TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            //--------------------------------
            // FRAGMENT
            //--------------------------------

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;

                //--------------------------------
                // CLOUDS
                //--------------------------------

                float2 cloudUV =
                    uv * _CloudScale;

                cloudUV.x +=
                    _Time.y * _CloudSpeed;

                float cloudNoise =
                    tex2D(_MainTex, cloudUV).r;

                float clouds =
                    smoothstep(
                        0.3,
                        0.8,
                        cloudNoise
                    );

                //--------------------------------
                // BASE SKY
                //--------------------------------

                fixed3 color =
                    lerp(
                        _SkyColor.rgb,
                        _CloudColor.rgb,
                        clouds
                    );

                //--------------------------------
                // RAIN
                //--------------------------------

                float2 rainUV = uv;

                // rainUV.y +=
                //     _Time.y * _RainSpeed;

                // rainUV.x *= _RainDensity;

                rainUV.y += _Time.y * _RainSpeed;

                rainUV.x *=  _RainDensity * 0.25;

                float column =
                    frac(rainUV.x);

                float rainMask =
                    step(column, _RainWidth);

                float rainNoise =
                    rand(
                        floor(rainUV.x)
                    );

                // float rain =
                //     rainMask *
                //     step(
                //         0.2,
                //         frac(rainUV.y + rainNoise)
                //     );

                    float rainLine =
                    frac(rainUV.y + rainNoise);

                float rain =
                    rainMask *
                    smoothstep(
                        0.95,
                        1.0,
                        rainLine
                    );

                color +=
                    rain * _RainColor.rgb * 0.35;

                //--------------------------------
                // LIGHTNING FLASH
                //--------------------------------

                // float lightning =
                //     sin(
                //         _Time.y
                //         * _LightningFrequency
                //     );

                // lightning =
                //     step(0.97, lightning);

                // float flash =
                //     lightning
                //     * _LightningIntensity;
                float lightningWave =
                        sin(_Time.y * _LightningFrequency);

                    float lightning =
                        smoothstep(
                            0.92,
                            1.0,
                            lightningWave
                        );

                    lightning *= lightning;

                    float flash =
                        lightning
                        * _LightningIntensity
                        * 0.08;

                //--------------------------------
                // LIGHTNING SHAPE
                //--------------------------------

                float2 boltUV = uv;

                boltUV.x +=
                    sin(uv.y * 20
                    + _Time.y * 40)
                    * 0.03;

                float bolt =
                    smoothstep(
                        0.5,
                        0.48,
                        abs(boltUV.x - 0.5)
                    );

                bolt *= lightning;

                //--------------------------------
                // APPLY LIGHTNING
                //--------------------------------

                // color +=
                //     flash * 0.25;
                //color += flash;

                // color +=
                //     bolt
                //     * _LightningColor.rgb
                //     * 4;

                return fixed4(color,1);
            }

            ENDCG
        }
    }
}