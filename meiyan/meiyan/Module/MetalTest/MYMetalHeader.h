//
//  MYMetalHeader.h
//  meiyan
//
//  Created by kzw on 2020/6/22.
//  Copyright © 2020 康子文. All rights reserved.
//

#ifndef MYMetalHeader_h
#define MYMetalHeader_h
#include <metal_stdlib>
using namespace metal;
//
struct Vertex{
    float4 position [[position]];
    float4 color;
};

#endif /* MYMetalHeader_h */
