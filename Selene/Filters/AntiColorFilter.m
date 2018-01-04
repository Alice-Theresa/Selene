//
//  AntiColorFilter.m
//  Selene
//
//  Created by Theresa on 2017/12/28.
//  Copyright © 2017年 Theresa. All rights reserved.
//

#import "AntiColorFilter.h"

@implementation AntiColorFilter

@synthesize glProgram = _glProgram;

- (instancetype)init {
    if (self = [super init]) {
        _glProgram = [SACShaderOperation compileVertex:@"AntiColor" fragment:@"AntiColor"];
    }
    return self;
}

@end
