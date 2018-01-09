//
//  SobelFilter.m
//  Selene
//
//  Created by Theresa on 2018/1/9.
//  Copyright © 2018年 Theresa. All rights reserved.
//

#import "SobelFilter.h"

@implementation SobelFilter

@synthesize glProgram = _glProgram;

- (instancetype)init {
    if (self = [super init]) {
        _glProgram = [SACShaderOperation compileVertex:@"Sobel" fragment:@"Sobel"];
    }
    return self;
}

@end
