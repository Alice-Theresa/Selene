//
//  GLRender.h
//  Selene
//
//  Created by Theresa on 2017/12/18.
//  Copyright © 2017年 Theresa. All rights reserved.
//

@import UIKit;
@import OpenGLES;

#import <Foundation/Foundation.h>

@interface GLRender : NSObject

- (instancetype)initWithImage:(UIImage *)image;
- (UIImage *)render;

@end
