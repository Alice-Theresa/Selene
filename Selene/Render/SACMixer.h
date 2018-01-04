//
//  SACMixer.h
//  Selene
//
//  Created by S.C. on 2017/12/31.
//  Copyright © 2017年 Theresa. All rights reserved.
//

@import UIKit;
@import OpenGLES;

@class SACChainRender;

#import <Foundation/Foundation.h>

@interface SACMixer : NSObject

@property (nonatomic, assign) GLuint width;
@property (nonatomic, assign) GLuint height;

- (instancetype)initWithRenderA:(SACChainRender *)render image:(UIImage *)image;
- (instancetype)initWithRenderA:(SACChainRender *)renderA renderB:(SACChainRender *)renderB;

- (void)render;
- (UIImage *)fetchImage;

@end
