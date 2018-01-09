//
//  ViewController.m
//  Selene
//
//  Created by Theresa on 2017/12/7.
//  Copyright © 2017年 Theresa. All rights reserved.
//

#import "ViewController.h"
#import "SACChainRender.h"
#import "SACMixer.h"
#import "AntiColorFilter.h"
#import "SobelFilter.h"
#import "GrayScaleFilter.h"
#import "SACContext.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    SACChainRender *r = [[SACChainRender alloc] initWithImage:[UIImage imageNamed:@"IMG_0227.jpg"]];
    [r addFilter:[[SobelFilter alloc] init]];
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
