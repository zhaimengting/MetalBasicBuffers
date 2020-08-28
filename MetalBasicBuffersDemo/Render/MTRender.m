//
//  MTRender.m
//  MetalBasicBuffersDemo
//
//  Created by mac on 2020/8/28.
//  Copyright © 2020 mac. All rights reserved.
//

#import "MTRender.h"
#import "MTShaderTypes.h"
@implementation MTRender
{
    //渲染设备
    id<MTLDevice>_device;
    //渲染管道:顶点着色器/片元着色器,存储于.metal shader文件中
    id<MTLRenderPipelineState> _pipelineState;
    //命令对流，从命令缓存区获取
    id<MTLCommandQueue> _commandQueue;
    //顶点缓存区
    id<MTLBuffer> _vertexBuffer;
    //当前视图大小
    vector_uint2 _viewportSize;
    NSInteger _numVertices;
}
-(instancetype)initWithMetalKitView:(MTKView *)mtkView{
    if (self = [super init]) {
        //初始化GPU设备
        _device = mtkView.device;
        //加载Metal文件
        [self loadMetal:mtkView];
    }
    return self;
}
-(void)loadMetal:(MTKView *)mtkView{
    //设置绘制纹理的像素格式
    mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
    //从项目中加载Metal着色器文件
    id<MTLLibrary>defaultLibrary = [_device newDefaultLibrary];
    id<MTLFunction>vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
    id<MTLFunction>fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];
    //配置用于创建管道状态的管道
    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc]init];
    pipelineDescriptor.label = @"Simple Pipeline";
    //可编程函数，用于处理渲染过程中各个顶点
    pipelineDescriptor.vertexFunction = vertexFunction;
    //可编程函数，用于处理渲染过程中的各个片元
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    //设置管道中存储颜色数据的组建格式
    pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
    //同步创建并返回渲染管线对象
    NSError *error = NULL;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
    if (!_pipelineState) {
        NSLog(@"Falid to created pipeline state,error %@",error);
    }
    //获取顶点数据
    NSData *vertexData = [MTRender generateVertexData];
    //创建一个顶点数组，由GPU来读取
    _vertexBuffer = [_device newBufferWithLength:vertexData.length options:MTLResourceStorageModeShared];
    //复制vertex data 到vertex buffer 通过缓存区的"content"内容属性访问指针
     /*
      memcpy(void *dst, const void *src, size_t n);
      dst:目的地
      src:源内容
      n: 长度
      */
    memcpy(_vertexBuffer.contents, vertexData.bytes, vertexData.length);
     //计算顶点个数 = 顶点数据长度 / 单个顶点大小
    _numVertices = vertexData.length/sizeof(MTVertex);
    //6.创建命令队列
    _commandQueue = [_device newCommandQueue];
}
+(NSData*)generateVertexData{
    //1.正方形 = 三角形+三角形
    const MTVertex quadVertices[] =
    {
        // Pixel 位置, RGBA 颜色
        { { -20,   20 },    { 1, 0, 0, 1 } },
        { {  20,   20 },    { 0, 1, 0, 1 } },
        { { -20,  -20 },    { 0, 0, 1, 1 } },
        
        { {  20,  -20 },    { 1, 0, 0, 1 } },
        { { -20,  -20 },    { 0, 1, 1, 1 } },
        { {  20,   20 },    { 1, 0, 1, 1 } },
    };
    //行数和列数
    const NSUInteger NUM_COLUMNS = 15;
    const NSUInteger NUM_ROWS = 15;
    //顶点个数
    const NSUInteger NUM_VERTICES_PER_QUAD = sizeof(quadVertices)/sizeof(MTVertex);
    //四边形间距
    const float QUAD_SPACING  = 50;
    //数据大小 = 单个四边形大小 * 行 * 列
    NSInteger dataSize = sizeof(quadVertices)*NUM_ROWS *NUM_COLUMNS;
     //2. 开辟空间
    NSMutableData *vertexData = [[NSMutableData alloc]initWithLength:dataSize];
        //当前四边形
    MTVertex *currentQuad  = vertexData.mutableBytes;
    //获取顶点坐标
    //行
    for (NSUInteger row = 0; row<NUM_ROWS; row++) {
        //列
        for (NSUInteger column = 0; column < NUM_COLUMNS; column++) {
            //左上角的位置
            vector_float2 upperLeftPostion;
             //计算X,Y 位置.注意坐标系基于2D笛卡尔坐标系,中心点(0,0),所以会出现负数位置
            upperLeftPostion.x = ((-((float)NUM_COLUMNS)/2.0)+column)*QUAD_SPACING+QUAD_SPACING/2.0;
    upperLeftPostion.y = ((-((float)NUM_ROWS)/2.0)+row)*QUAD_SPACING+QUAD_SPACING/2.0;
            memcpy(currentQuad, &quadVertices, sizeof(quadVertices));
            //遍历currenQuad中的数据
            for (NSUInteger vertexInQuad = 0; vertexInQuad < NUM_VERTICES_PER_QUAD; vertexInQuad++) {
              //修改vertexInQuad中的position
                currentQuad[vertexInQuad].position += upperLeftPostion;
            }
            currentQuad += 6;
        }
    }
    return vertexData;
}
#pragma mark - MTKView Delegate
//每当视图改变方向或者调整大小时调用
-(void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
     // 保存可绘制的大小，因为当我们绘制时，我们将把这些值传递给顶点着色器
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}
-(void)drawInMTKView:(MTKView *)view{
     //1.为当前渲染的每个渲染传递创建一个新的命令缓冲区
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"Mycommand";
    //2. MTLRenderPassDescriptor:一组渲染目标，用作渲染通道生成的像素的输出目标。
    //currentRenderPassDescriptor 从currentDrawable's texture,view's depth, stencil, and sample buffers and clear values.
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor!=nil) {
        id<MTLRenderCommandEncoder>renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"RenderEncoder";
        [renderEncoder setViewport:(MTLViewport){0.0,0.0,_viewportSize.x,_viewportSize.y,-1.0,1.0}];
        [renderEncoder setRenderPipelineState:_pipelineState];
        [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:MTVertexInputIndexVertex];
        [renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:MTVertexInputIndexViewportSize];
        //开始绘图
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_numVertices];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    [commandBuffer commit];
}
@end
