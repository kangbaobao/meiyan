//
//  TextureShader.metal
//  meiyan
//
//  Created by kzw on 2020/6/23.
//  Copyright © 2020 康子文. All rights reserved.
//

#include <metal_stdlib>
//#include "MYMetalHeader.h"
using namespace metal;
//渲染纹理使用的
struct TextureVertex{
    float4 position [[position]];
    //纹理坐标
    float2 textureCoordinate;
};
vertex  TextureVertex  textureVertext_func(
                                           uint vid [[vertex_id]],
                                           constant TextureVertex *vertices[[buffer(0)]]
                                            ){
    TextureVertex out;
    out.position = vertices[vid].position;
    out.textureCoordinate = vertices[vid].textureCoordinate;
    return out;
}
fragment float4 textureFragment_func(TextureVertex input [[stage_in]],
                                     texture2d<half> colorTexture [[texture(0)]]){
    
    constexpr sampler textureSampler(mag_filter::linear,min_filter::nearest); //min_filter::nearest
    half4 color = colorTexture.sample(textureSampler, input.textureCoordinate);
    return float4(color);
//    float4 color(1.0,0.0,0.0,1.0);
//    return color;
}


