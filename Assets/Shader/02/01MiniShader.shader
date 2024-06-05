Shader "ShaderLearning/Builtin/01MiniShader"
{
    Properties
    {
        _MainTexture("Main Texture", 2D) = "white"{}
    }
    
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTexture;
            float4 _MainTexture_ST;

            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * _MainTexture_ST.xy + _MainTexture_ST.zw;
                
                return  o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTexture, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
