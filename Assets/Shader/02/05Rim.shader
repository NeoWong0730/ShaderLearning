Shader "ShaderLearning/Builtin/05Rim"
{
    Properties
    {
        _MainTexture("Main Texture", 2D) = "white"{}
        _MainColor("Main Color", Color) = (1, 1, 1, 1)
        _Emiss("Emiss", Float) = 1.0
        _RimPower("RimPower", Float) = 1.0
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", float) = 2
    }
    
    SubShader
    {
        Tags {"Queue" = "Transparent"}
        Pass
        {
            Cull Off
            ZWrite On
            ColorMask 0
            CGPROGRAM
            #pragma vertex vert
            #pragma  fragment frag
            
            float4 _Color;
            
            float4 vert(float4 vertexPos: POSITION): SV_POSITION
            {
                return UnityObjectToClipPos(vertexPos);
            }

            float4 frag(void): COLOR
            {
                return  _Color;
            }
            ENDCG
        }

        Pass
        {
            ZWrite Off
            Blend SrcAlpha One
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                half2 uv: TEXCOORD0;
                half3 normal: NORMAL;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
                float3 normal_world: TEXCOORD1;
                float3 view_world: TEXCOORD2;

            };

            sampler2D _MainTexture;
            float4 _MainTexture_ST;
            float4 _MainColor;
            float _Emiss;
            float _RimPower;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * _MainTexture_ST.xy + _MainTexture_ST.zw;
                o.normal_world = normalize(mul(float4(v.normal, 0), unity_WorldToObject).xyz);
                float3 pos_world = mul(unity_ObjectToWorld, v.vertex);
                o.view_world = normalize(_WorldSpaceCameraPos.xyz - pos_world);

                return o;
            }

            half4 frag(v2f i): SV_Target
            {
                float3 normal_world = normalize(i.normal_world);
                float3 view_world = normalize(i.view_world);
                float NdotV = saturate((dot(normal_world, view_world)));
                float3 col = _MainColor.xyz * _Emiss;
                float3 finalColor = tex2D(_MainTexture, i.uv).xyz;
                float fresnel = pow(1.0 - NdotV, _RimPower);
                float alpha = saturate(fresnel * _Emiss);

                return float4(finalColor, alpha);
            }
            ENDCG
        }
    }
}