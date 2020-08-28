//
//  MTRender.h
//  MetalBasicBuffersDemo
//
//  Created by mac on 2020/8/28.
//  Copyright © 2020 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface MTRender : NSObject<MTKViewDelegate>
//初始化
-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView*)mtkView;
@end

NS_ASSUME_NONNULL_END
