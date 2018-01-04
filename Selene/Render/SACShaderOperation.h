//
//  SACShaderOperation.h
//  Selene
//
//  Created by Theresa on 2017/12/11.
//  Copyright © 2017年 Theresa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>

@interface SACShaderOperation : NSObject

+ (GLuint)compileShader:(NSString *)shaderName withType:(GLenum)shaderType;
+ (GLuint)compileVertex:(NSString *)shaderVertex fragment:(NSString *)shaderFragment;

@end
