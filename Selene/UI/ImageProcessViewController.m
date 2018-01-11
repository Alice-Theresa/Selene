//
//  ImageProcessViewController.m
//  Selene
//
//  Created by Theresa on 2018/1/11.
//  Copyright © 2018年 Theresa. All rights reserved.
//

#import "ImageProcessViewController.h"
#import "SACChainRender.h"
#import "SACMixer.h"
#import "AntiColorFilter.h"
#import "SobelFilter.h"
#import "GrayScaleFilter.h"
#import "SACContext.h"

@interface ImageProcessViewController ()

@end

@implementation ImageProcessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SACChainRender *r = [[SACChainRender alloc] initWithImage:[UIImage imageNamed:@"IMG_0227.jpg"]];
    [r addFilter:[[SobelFilter alloc] init]];
    [r addFilter:[[AntiColorFilter alloc] init]];
    //    SACChainRender *r2 = [[SACChainRender alloc] initWithImage:[UIImage imageNamed:@"Beauty.jpeg"]];
    //    [r2 addFilter:[[AntiColorFilter alloc] init]];
    //
    //    SACMixer *m = [[SACMixer alloc] initWithRenderA:r renderB:r2];
    //    [m render];
    [r startRender];
    UIImage *i = [r fetchImage];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:i];
    iv.frame = self.view.bounds;
    [self.view addSubview:iv];
}

@end
