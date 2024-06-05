Shader "ShaderLearning/Builtin/03Clip"
{
    Properties
    {
        _MainTexture("Main Texture", 2D) = "white"{}
        _MainColor("Main Color", Color) = (1, 1, 1, 1)
        _Cutout("Cutout", Range(0, 1)) = 0
        _Speed("Speed",Vector) = (1, 1, 0, 0)
        _NoiseTexture("Noise Texture", 2D) = "white"{}
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", float) = 2
    }
    
    SubShader
    {
        Pass
        {
            Cull [_CullMode]
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTexture;
            float4 _MainTexture_ST;
            float _Cutout;
            float4 _Speed;
            sampler2D _NoiseTexture;
            float4 _NoiseTexture_ST;
            float4 _MainColor;

            struct appdata
            {
                float4 vertex: POSITION;
                half2 uv: TEXCOORD0;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
                float2 pos_uv: TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * _MainTexture_ST.xy + _MainTexture_ST.zw;
                float4 pos_world = mul(unity_ObjectToWorld, v.vertex);
                o.pos_uv = pos_world.xz * _MainTexture_ST.xy + _MainTexture_ST.zw;
                
                return  o;
            }

            half4 frag(v2f i): SV_Target
            {
                half gradient = tex2D(_MainTexture, i.uv + _Time.y * _Speed.xy).r;
                half noise = tex2D(_NoiseTexture, i.uv + _Time.y * _Speed.zw).r;
                clip(gradient - noise -_Cutout);
                return _MainColor;
                //return gradient.xxxx;
            }
            
            ENDCG
        }
    }
}
