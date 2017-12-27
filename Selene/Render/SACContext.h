//
//  SACContext.h
//  Selene
//
//  Created by Theresa on 2017/12/27.
//  Copyright © 2017年 Theresa. All rights reserved.
//

@import OpenGLES;

#import <Foundation/Foundation.h>

@interface SACContext : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sharedContext;
- (void)setCurrentContext;

@end
