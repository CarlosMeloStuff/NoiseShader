﻿Shader "Hidden/Noise/Delta"
{
    Properties
    {
        _MainTex("-", 2D) = ""{}
    }

    CGINCLUDE

    sampler2D _MainTex;
    float2 _MainTex_TexelSize;

    #include "UnityCG.cginc"
    #include "ClassicNoise3D.cginc"

    float4 frag_offs(v2f_img i) : SV_Target 
    {
        float3 vp = tex2D(_MainTex, i.uv).xyz;

        float3 np = float3(i.uv.x * 10, i.uv.y * 10, 0);
        float3 no = float3(0.1, 0.2, 0) * _Time.y * 0;

        float n1 =
            cnoise(np * 1 + no) +
            cnoise(np * 2 + no) * 0.5 +
            cnoise(np * 4 + no) * 0.25;

        no += float3(0, 0, 5.3);

        float n2 =
            cnoise(np * 1 + no) +
            cnoise(np * 2 + no) * 0.5 +
            cnoise(np * 4 + no) * 0.25;

        no += float3(0, 0, 5.3);

        float n3 =
            cnoise(np * 1 + no) +
            cnoise(np * 2 + no) * 0.5 +
            cnoise(np * 4 + no) * 0.25;

        float3 v1 = normalize(vp * float3(-1, -1, 0));
        float3 v2 = float3(0, 0, 1);
        float3 v3 = cross(v1, v2);

        vp += (v1 * (max(n1-0.3, 0) + 0.3 * n1) * 2 + v2 * n2 * 0.3 + v3 * n3 * 0.3) * 5;

        return float4(vp, 0);
    }

    float4 frag_norm1(v2f_img i) : SV_Target 
    {
        float2 duv = _MainTex_TexelSize;

        float3 v1 = tex2D(_MainTex, i.uv).xyz;
        float3 v2 = tex2D(_MainTex, i.uv + float2(0, duv.y)).xyz;
        float3 v3 = tex2D(_MainTex, i.uv + duv).xyz;

        float3 n = normalize(cross(v2 - v1, v3 - v2));

        return float4(n, 0);
    }

    float4 frag_norm2(v2f_img i) : SV_Target 
    {
        float2 duv = _MainTex_TexelSize;

        float3 v1 = tex2D(_MainTex, i.uv).xyz;
        float3 v2 = tex2D(_MainTex, i.uv + duv).xyz;
        float3 v3 = tex2D(_MainTex, i.uv + float2(duv.x, 0)).xyz;

        float3 n = normalize(cross(v2 - v3, v3 - v1));

        return float4(n, 0);
    }

    ENDCG

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma glsl
            #pragma vertex vert_img
            #pragma fragment frag_offs
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma glsl
            #pragma vertex vert_img
            #pragma fragment frag_norm1
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma glsl
            #pragma vertex vert_img
            #pragma fragment frag_norm2
            ENDCG
        }
    }
}