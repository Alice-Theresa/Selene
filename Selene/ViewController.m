//
//  ViewController.m
//  Selene
//
//  Created by Theresa on 2017/12/7.
//  Copyright © 2017年 Theresa. All rights reserved.
//

#import "ViewController.h"
#import "GLRender.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    GLRender *r = [[GLRender alloc] initWithImage:[UIImage imageNamed:@"IMG_0227.jpg"]];
    UIImage *i = [r render];
}

@end
