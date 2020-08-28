//
//  MTShaderTypes.h
//  MetalBasicBuffersDemo
//
//  Created by mac on 2020/8/28.
//  Copyright © 2020 mac. All rights reserved.
//

#ifndef MTShaderTypes_h
#define MTShaderTypes_h
#include<simd/simd.h>

typedef enum MTVertexInputIndex{
    //顶点
    MTVertexInputIndexVertex = 0,
    //视口大小
    MTVertexInputIndexViewportSize = 1,
}MTVertexInputIndex;

typedef struct{
    //像素空间的位置
    vector_float2 position;
    //RGBA颜色
    vector_float4 color;
}MTVertex;

#endif /* MTShaderTypes_h */
