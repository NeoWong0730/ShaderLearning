Shader "ShaderLearning/Builtin/04Blending"
{
    Properties
    {
        _MainTexture("Main Texture", 2D) = "White"{}
        _MainColor("Main Color", Color) = (1, 1, 1, 1)
        _Emiss("Emiss", Float) = 1.0
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 2 
    }
    
    SubShader
    {
        Tags {"Queue" = "Transparent"}
        Pass
        {
            ZWrite Off
            //Blend SrcAlpha OneMinusSrcAlpha
            Blend SrcAlpha One
            Cull [_CullMode]
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTexture;
            float4 _MainTexture_ST;
            half4 _MainColor;
            float _Emiss;

            struct appdata
            {
                float4 vertex: POSITION;
                half2 uv: TEXCOORD0;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                half2 uv: TEXCOORD0;
                float2 pos_uv: TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * _MainTexture_ST.xy + _MainTexture_ST.zw;
                o.pos_uv = mul(unity_ObjectToWorld, v.vertex).xz * _MainTexture_ST.xy + _MainTexture_ST.zw;

                return  o;
            }

            half4 frag(v2f i): SV_Target
            {
                half3 col = _MainColor.xyz * _Emiss;
                half alpha = saturate(tex2D(_MainTexture, i.uv).r * _MainColor.a * _Emiss);

                return  half4(col, alpha);
            }
            ENDCG
        }
    }
}