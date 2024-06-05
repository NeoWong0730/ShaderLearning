Shader "ShaderLearning/Builtin/02Texturing"
{
   Properties
   {
      _MainTexture("Main Texture", 2D) = "white"{}
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

         struct appdata
         {
            float4 vertex: POSITION;
            half2 uv: TEXCOORD0;
         };

         struct v2f
         {
            float4 pos: SV_POSITION;
            half2 uv: TEXCOORD0;
         };
         
         sampler2D _MainTexture;
         float4 _MainTexture_ST;

         v2f vert(appdata v)
         {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv * _MainTexture_ST.xy + _MainTexture_ST.zw;

            return o;
         }

         half4 frag(v2f i): SV_Target
         {
            return tex2D(_MainTexture, i.uv);
         }
         ENDCG
      }
   }
}
