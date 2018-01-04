//
//  GrayScaleFilter.m
//  Selene
//
//  Created by Theresa on 2017/12/28.
//  Copyright © 2017年 Theresa. All rights reserved.
//

#import "GrayScaleFilter.h"

@implementation GrayScaleFilter

@synthesize glProgram = _glProgram;

- (instancetype)init {
    if (self = [super init]) {
        _glProgram = [SACShaderOperation compileVertex:@"GrayScale" fragment:@"GrayScale"];
    }
    return self;
}

@end
