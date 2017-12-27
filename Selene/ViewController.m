//
//  ViewController.m
//  Selene
//
//  Created by Theresa on 2017/12/7.
//  Copyright © 2017年 Theresa. All rights reserved.
//

#import "ViewController.h"
#import "SACRender.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    SACRender *r = [[SACRender alloc] initWithImage:[UIImage imageNamed:@"IMG_0227.jpg"]];
    UIImage *i = [r fetchImage];
    UIImageView *iv = [[UIImageView alloc] initWithImage:i];
    iv.frame = self.view.bounds;
    [self.view addSubview:iv];
}

@end
