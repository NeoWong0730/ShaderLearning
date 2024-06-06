Shader "ShaderLearning/Builtin/MatCap"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white"{}
        _MatCap("MatCap", 2D) = "white"{}
        _MatCapIntensity("MatCap Intensity", Float) = 1.0
        _RampTex("Ram Texture", 2D) = "white"{}
        _MatCapAdd("MatCapAdd Texture", 2D) = "white"{}
        _MatCapAddIntensity("MatCapAdd Intensity", Float) = 1.0
    }
    
    SubShader
    {
        Tags {"Queue" = "Opaque"}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {   
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
                float3 normal_world: TEXCOORD1;
                float3 pos_world: TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _MatCap;
            float _MatCapIntensity;
            sampler2D _RampTex;
            sampler2D _MatCapAdd;
            float _MatCapAddIntensity;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float3 normal_world = mul(float4(v.normal, 0.0), unity_ObjectToWorld).xyz;
                o.normal_world = normal_world;
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            half4 frag(v2f i): SV_Target
            {
                half3 normal_world = normalize(i.normal_world);

                //diffuse
                half4 diffuse_color = tex2D(_MainTex, i.uv);

                //base matcap
                half3 normal_viewspace = mul(UNITY_MATRIX_V, float4(normal_world, 0.0)).xyz;
                half2 uv_matcap = (normal_viewspace.xy + float2(1.0, 1.0)) * 0.5;
                half4 matcap_color = tex2D(_MatCap, uv_matcap) * _MatCapIntensity;

                //Ramp
                half3 view_dir = normalize(_WorldSpaceCameraPos - i.pos_world);
                half NdotV = saturate(dot(normal_world, view_dir));
                half fresnel = 1.0 - NdotV;
                half2 uv_ramp = half2(fresnel, 0.5);
                half4 ramp_color = tex2D(_RampTex, uv_ramp);

                //add matcap
                half4 matcap_add_color = tex2D(_MatCapAdd, uv_matcap) * _MatCapAddIntensity;

                half4 final_color = diffuse_color * matcap_color * ramp_color + matcap_add_color;

                return  final_color;
            }
            
            ENDCG
        }
    }
}