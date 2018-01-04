//
//  SACMixer.h
//  Selene
//
//  Created by S.C. on 2017/12/31.
//  Copyright © 2017年 Theresa. All rights reserved.
//

@import UIKit;
@import OpenGLES;

@class SACRender;

#import <Foundation/Foundation.h>

@interface SACMixer : NSObject

- (instancetype)initWithRenderA:(SACRender *)render image:(UIImage *)image;
- (instancetype)initWithRenderA:(SACRender *)renderA renderB:(SACRender *)renderB;

- (void)render;
- (UIImage *)fetchImage;

@end
