//
//  GLRender.m
//  Selene
//
//  Created by Theresa on 2017/12/18.
//  Copyright © 2017年 Theresa. All rights reserved.
//

#import "GLRender.h"
#import "ShaderOperation.h"

@implementation GLRender {
    GLuint _width;
    GLuint _height;
    GLubyte *_imageData;
    
    EAGLContext *_context;
    
    GLuint _texture;
    GLuint _texture2;
    
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    GLuint _frameBuffer2;
    
    GLuint _glProgram;
    GLuint _positionSlot;
    GLuint _coordSlot;
    
    GLuint _glProgram2;
    GLuint _positionSlot2;
    GLuint _coordSlot2;
}

- (void)dealloc {
    [self cleanBuffer];
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        [self setupImage:image];
        [self setupContext];
        [self setupGLProgram];
        [self setupTexture];
        [self setupVBO];
        [self setupTemp];
        [self render];
        [self setup2];
        [self setupTemp2];
        [self render];
    }
    return self;
}

- (void)setupImage:(UIImage *)image {
    _width = image.size.width;
    _height = image.size.height;
    CGImageRef cgImage = image.CGImage;
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    _imageData = (GLubyte *)CFDataGetBytePtr(data);
}

- (void)setupContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 3.0 context");
        exit(1);
    }
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupGLProgram {
    _glProgram = [ShaderOperation compileVertex:@"vert" fragment:@"frag"];
    glUseProgram(_glProgram);
    _positionSlot = glGetAttribLocation(_glProgram, "position");
    _coordSlot = glGetAttribLocation(_glProgram, "texcoord");
}

- (void)setupTexture {
    glActiveTexture(GL_TEXTURE0);
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, _imageData);
    glUniform1f(glGetAttribLocation(_glProgram, "image"), 0);
}

- (void)setupTemp {
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1, &_texture2);
    glBindTexture(GL_TEXTURE_2D, _texture2);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture2, 0);
}

- (void)setup2 {
    _glProgram2 = [ShaderOperation compileVertex:@"vertex" fragment:@"fragment"];
    glUseProgram(_glProgram);
    _positionSlot = glGetAttribLocation(_glProgram2, "position");
    _coordSlot = glGetAttribLocation(_glProgram2, "texcoord");
}

- (void)setupTemp2 {
    GLuint texture3;
    glActiveTexture(GL_TEXTURE2);
    glGenTextures(1, &texture3);
    glBindTexture(GL_TEXTURE_2D, texture3);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glUniform1f(glGetAttribLocation(_glProgram2, "image"), 1);
    
    glGenFramebuffers(1, &_frameBuffer2);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer2);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture3, 0);
}

- (void)cleanBuffer {
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    glDeleteFramebuffers(1, &_frameBuffer);
    _colorRenderBuffer = 0;
    _frameBuffer = 0;
}

- (void)setupVBO {
    GLfloat vertices[] = {
        1.0f,  1.0f, 0.0f, 1.0f, 0.0f,   // 右上
        1.0f, -1.0f, 0.0f, 1.0f, 1.0f,   // 右下
        -1.0f, -1.0f, 0.0f, 0.0f, 1.0f,  // 左下
        -1.0f, -1.0f, 0.0f, 0.0f, 1.0f,  // 左下
        -1.0f,  1.0f, 0.0f, 0.0f, 0.0f,  // 左上
        1.0f,  1.0f, 0.0f, 1.0f, 0.0f,   // 右上
    };
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, 0);
    glEnableVertexAttribArray(_positionSlot);
    
    glVertexAttribPointer(_coordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL + sizeof(GL_FLOAT) * 3);
    glEnableVertexAttribArray(_coordSlot);
}

- (void)render {
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, _width, _height);
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

- (UIImage *)fetchImage {
    GLuint totalBytesForImage = _width * _height * 4;
    GLubyte *rawImagePixels = (GLubyte*)malloc(totalBytesForImage * sizeof(GLubyte));
    
    glReadPixels(0, 0, _width, _height, GL_RGBA, GL_UNSIGNED_BYTE, rawImagePixels);
    
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rawImagePixels, totalBytesForImage, NULL);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImageFromBytes = CGImageCreate(_width,
                                                _height,
                                                8,
                                                32,
                                                4 * _width,
                                                colorSpace,
                                                kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                                dataProvider,
                                                NULL,
                                                YES,
                                                kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(colorSpace);
//    free(rawImagePixels); bug
    return [UIImage imageWithCGImage:cgImageFromBytes];
}

@end
