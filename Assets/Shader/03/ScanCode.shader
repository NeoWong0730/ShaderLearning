Shader "ShaderLearning/Builtin/ScanCode"
{
    Properties
    {
        _MainTexture("Main Texture", 2D) = "white"{}
        _RimMin("RimMin", Range(-1, 1)) = 0.0
        _RimMax("RimMax", Range(0, 2)) = 1.0
        _InnerColor("Inner Color", Color) = (0, 0, 0, 0)
        _RimColor("Rim Color", Color) = (1, 1, 1, 1)
        _RimIntensity("Rim Intensity", Float) = 1.0
        _FlowTilling("Flow Tilling", Vector) = (1, 1, 0, 0)
        _FlowSpeed("Flow Speed", Vector) = (1, 1, 0, 0)
        _FlowTexture("Flow Texture", 2D) = "white"{}
        _FlowIntensity("Flow Intensity", Float) = 0.5
        _InnerAlpha("Inner Alpha", Range(0, 1)) = 0
    }
    
    SubShader
    {
        Tags { "Queue" = "Transparent" }
        LOD 100
        
        Pass
        {
            ZWrite Off
            Blend SrcAlpha One
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTexture;
            float4 _MainTexture_ST;
            float _RimMin;
            float _RimMax;
            float4 _InnerColor;
            float4 _RimColor;
            float _RimIntensity;
            float4 _FlowTilling;
            float4 _FlowSpeed;
            sampler2D _FlowTexture;
            float _FlowIntensity;
            float _InnerAlpha;
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 pos: POSITION;
                float2 uv: TEXCOORD0;
                float3 pos_world: TEXCOORD1;
                float3 normal_world: TEXCOORD2;
                float3 pivot_world: TEXCOORD3;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 normal_world = mul(float4(v.normal, 0.0), unity_ObjectToWorld);
                float3 pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal_world = normalize(normal_world);
                o.pos_world = pos_world;
                o.pivot_world = mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0));
                o.uv = v.uv * _MainTexture_ST.xy + _MainTexture_ST.zw;

                return o;
            }

            half4 frag(v2f i): SV_Target
            {
                half3 normal_world = normalize(i.normal_world);
                half3 view_world = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                half NdotV = saturate(dot(normal_world, view_world));
                half fresnel = 1.0 - NdotV;
                fresnel = smoothstep(_RimMin, _RimMax, fresnel);
                half emiss = tex2D(_MainTexture, i.uv).r;
                emiss = pow(emiss, 5.0);

                half final_fresnel = saturate(fresnel + emiss);

                half3 final_rim_color = lerp(_InnerColor.xyz, _RimColor.xyz * _RimIntensity, final_fresnel);
                half final_rim_alpha = final_fresnel;

                half2 uv_flow = (i.pos_world.xy - i.pivot_world.xy) * _FlowTilling;
                uv_flow = uv_flow + _Time.y * _FlowSpeed.xy;
                half4 flow_rgba = tex2D(_FlowTexture, uv_flow) * _FlowIntensity;

                half3 final_color = final_rim_color + flow_rgba.xyz;
                half final_alpha = saturate(final_rim_alpha + flow_rgba.a + _InnerAlpha);

                return half4(final_color, final_alpha);
            }
            
            ENDCG
        }
    }
}