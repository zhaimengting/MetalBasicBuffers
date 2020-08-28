//
//  ViewController.m
//  MetalBasicBuffersDemo
//
//  Created by mac on 2020/8/28.
//  Copyright © 2020 mac. All rights reserved.
//

#import "ViewController.h"
#import "MTRender.h"

@interface ViewController (){
    MTKView *_view;
    MTRender *_render;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _view = [[MTKView alloc]initWithFrame:self.view.frame device:MTLCreateSystemDefaultDevice()];
    _render = [[MTRender alloc]initWithMetalKitView:_view];
    if(!_render)
    {
        NSLog(@"Renderer failed initialization");
        return;
    }
    [_render mtkView:_view drawableSizeWillChange:_view.drawableSize];
    _view.delegate = _render;
    [self.view addSubview:_view];
}


@end
