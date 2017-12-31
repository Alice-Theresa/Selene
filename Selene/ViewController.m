//
//  ViewController.m
//  Selene
//
//  Created by Theresa on 2017/12/7.
//  Copyright © 2017年 Theresa. All rights reserved.
//

#import "ViewController.h"
#import "SACRender.h"
#import "SACMixer.h"
#import "AntiColorFilter.h"
#import "GrayScaleFilter.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    SACRender *r = [[SACRender alloc] initWithImage:[UIImage imageNamed:@"IMG_0227.jpg"]];
    [r addFilter:[[GrayScaleFilter alloc] init]];
    [r addFilter:[[AntiColorFilter alloc] init]];
    [r startRender];
    SACMixer *m = [[SACMixer alloc] initWithRenderA:r renderB:nil];
    [m render];
    UIImage *i = [m fetchImage];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:i];
    iv.frame = self.view.bounds;
    [self.view addSubview:iv];
}

@end
