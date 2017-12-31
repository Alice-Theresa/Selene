//
//  SACRender.h
//  Selene
//
//  Created by Theresa on 2017/12/18.
//  Copyright © 2017年 Theresa. All rights reserved.
//

@import UIKit;
@import OpenGLES;

@class SACFilter;

#import <Foundation/Foundation.h>

@interface SACRender : NSObject

@property (nonatomic, assign) GLuint width;
@property (nonatomic, assign) GLuint height;

- (instancetype)initWithImage:(UIImage *)image;
- (void)addFilter:(SACFilter *)filter;
- (GLuint)fetchTexture;
- (void)startRender;
- (UIImage *)fetchImage;

@end
