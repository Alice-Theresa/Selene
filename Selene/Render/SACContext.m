//
//  SACContext.m
//  Selene
//
//  Created by Theresa on 2017/12/27.
//  Copyright © 2017年 Theresa. All rights reserved.
//

#import "SACContext.h"

@interface SACContext ()

@property (nonatomic, strong) EAGLContext *context;

@end

@implementation SACContext

+ (instancetype)sharedContext {
    static SACContext *sharedContext;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedContext = [[self alloc] init];
    });
    return sharedContext;
}

- (instancetype)init {
    if (self = [super init]) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    }
    return self;
}

- (void)setCurrentContext {
    [EAGLContext setCurrentContext:_context]; //todo check bool
}

@end
