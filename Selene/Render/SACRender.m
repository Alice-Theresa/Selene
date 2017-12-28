//
//  SACRender.m
//  Selene
//
//  Created by Theresa on 2017/12/18.
//  Copyright © 2017年 Theresa. All rights reserved.
//

#import "SACRender.h"
#import "ShaderOperation.h"
#import "SACContext.h"
#import "SACFilter.h"

@interface SACRender ()

@property (nonatomic, strong) NSMutableArray * filters;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation SACRender {
    GLuint _width;
    GLuint _height;
    GLubyte *_imageData;
    
    GLuint _originTexture;
    GLuint _outputTexture;
    
    GLuint _frameBuffer;
    GLuint _frameBuffer2;
    
    GLuint _glProgram;
    GLuint _positionSlot;
    GLuint _coordSlot;
    
    GLuint _glProgram2;
}

- (void)dealloc {
    [self cleanBuffer];
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        _queue = dispatch_queue_create("com.opengl.queue", 0);
        _filters = [NSMutableArray array];
        
        [self setupImage:image];
        [self setupContext];
        [self setupGLProgram];
        [self setupRenderTexture];
        [self setupVBO];
        [self activeVBO];
        [self setupOutputTarget];
        [self render];
//        [self setup2];
//        [self setupTemp2];
//        [self render];
    }
    return self;
}

- (void)cleanBuffer {
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
}

- (void)setupImage:(UIImage *)image {
    _width = image.size.width;
    _height = image.size.height;
    CGImageRef cgImage = image.CGImage;
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    _imageData = (GLubyte *)CFDataGetBytePtr(data);
}

- (void)setupContext {
    [[SACContext sharedContext] setCurrentContext];
}

- (void)setupGLProgram {
    _glProgram = [ShaderOperation compileVertex:@"Origin" fragment:@"Origin"];
    glUseProgram(_glProgram);
    _positionSlot = glGetAttribLocation(_glProgram, "position");
    _coordSlot = glGetAttribLocation(_glProgram, "texcoord");
}

- (void)setupRenderTexture {
    glActiveTexture(GL_TEXTURE0);
    glGenTextures(1, &_originTexture);
    glBindTexture(GL_TEXTURE_2D, _originTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, _imageData);
    glUniform1i(glGetUniformLocation(_glProgram, "image"), 0);
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
}

- (void)activeVBO {
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, 0);
    glEnableVertexAttribArray(_positionSlot);
    
    glVertexAttribPointer(_coordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL + sizeof(GL_FLOAT) * 3);
    glEnableVertexAttribArray(_coordSlot);
}

- (void)setupOutputTarget {
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1, &_outputTexture);
    glBindTexture(GL_TEXTURE_2D, _outputTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _outputTexture, 0);
}

- (void)render {
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, _width, _height);
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

#pragma mark - public

- (void)addFilter:(SACFilter *)filter {
    [self.filters addObject:filter];
}

- (void)loopFilters {
    GLint i = 1;
    for (SACFilter *filter in self.filters) {
        [self setupContext];
        glUseProgram(filter.glProgram);
        _positionSlot = glGetAttribLocation(filter.glProgram, "position");
        _coordSlot = glGetAttribLocation(filter.glProgram, "texcoord");
        glActiveTexture(GL_TEXTURE0 + i + 1);
        GLuint texture;
        glGenTextures(1, &texture);
        glBindTexture(GL_TEXTURE_2D, texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
        glUniform1i(glGetUniformLocation(_glProgram, "image"), i);
        
        glGenFramebuffers(1, &_frameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);
        [self render];
        i++;
    }
}

- (UIImage *)fetchImage {
    GLuint totalBytesForImage = _width * _height * 4;
    GLubyte *rawImagePixels = (GLubyte *)malloc(totalBytesForImage * sizeof(GLubyte));
    
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
