//
//  ModelShaders.metal
//  meiyan
//
//  Created by kzw on 2020/6/22.
//  Copyright © 2020 康子文. All rights reserved.
//

#include <metal_stdlib>
#include "MYMetalHeader.h"

using namespace metal;

struct Uniforms{
    float4x4 modelMatrix;
};
vertex Vertex modelVertext_func(constant Vertex *vertices [[buffer(0)]],
                                constant Uniforms &uniforms [[buffer(1)]], //
                                uint vid [[vertex_id]]){
    float4x4 martix = uniforms.modelMatrix;
    Vertex in = vertices[vid];
    Vertex out ;
    out.position = martix * float4(in.position);
    out.color = in.color;
    return out;
}
fragment float4 modelFragment_func(Vertex vert[[stage_in]]){
    return vert.color;//half4(vert.color);
}

