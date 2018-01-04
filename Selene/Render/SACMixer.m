//
//  SACMixer.m
//  Selene
//
//  Created by S.C. on 2017/12/31.
//  Copyright © 2017年 Theresa. All rights reserved.
//

#import "SACMixer.h"
#import "SACRender.h"
#import "SACContext.h"
#import "ShaderOperation.h"

@interface SACMixer ()

@property (nonatomic, strong) SACRender *renderA;

@end

@implementation SACMixer {
    GLuint _width;
    GLuint _height;
    GLubyte *_imageData;
    
    GLuint _texture2;
    GLuint _texture3;
    GLuint _texture4;
    GLuint _frameBuffer;
    
    GLuint _glProgram;
    GLuint _positionSlot;
    GLuint _coordSlot;
}

- (instancetype)initWithRenderA:(SACRender *)render image:(UIImage *)image {
    if (self = [super init]) {
        _width = render.width;
        _height = render.height;
        _renderA = render;
        
        // TODO:
        if (image.size.width != _width && image.size.height != _height) {
            
        }
        
        CGImageRef cgImage = image.CGImage;
        CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
        _imageData = (GLubyte *)CFDataGetBytePtr(data);
        
        [self setupContext];
        [self setupGLProgram];
        [self setupRenderTexture];
        [self setupImageTexture];
        
        [self setupVBO];
        [self activeVBO];
        [self setupOutputTarget];
    }
    return self;
}

// TODO: B
- (instancetype)initWithRenderA:(SACRender *)renderA renderB:(SACRender *)renderB {
    if (self = [super init]) {
        _width = renderA.width;
        _height = renderA.height;
        _renderA = renderA;
        
        [self setupContext];
        [self setupGLProgram];
        [self setupRenderTexture];
        
        [self setupVBO];
        [self activeVBO];
        [self setupOutputTarget];
    }
    return self;
}

- (void)setupContext {
    [[SACContext sharedContext] setCurrentContext];
}

- (void)setupGLProgram {
    _glProgram = [ShaderOperation compileVertex:@"Mixer" fragment:@"Mixer"];
    glUseProgram(_glProgram);
    _positionSlot = glGetAttribLocation(_glProgram, "position");
    _coordSlot = glGetAttribLocation(_glProgram, "texcoord");
}

- (void)setupRenderTexture {
    GLuint fbo;
    glGenFramebuffers(1, &fbo);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, fbo);
    glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, [self.renderA fetchTexture], 0);
    
    glActiveTexture(GL_TEXTURE2);
    glGenTextures(1, &_texture2);
    glBindTexture(GL_TEXTURE_2D, _texture2);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 0, 0, _width, _height, 0);
    glUniform1i(glGetUniformLocation(_glProgram, "image1"), 2);
}

- (void)setupImageTexture {
    glActiveTexture(GL_TEXTURE3);
    glGenTextures(1, &_texture3);
    glBindTexture(GL_TEXTURE_2D, _texture3);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, _imageData);
    glUniform1i(glGetUniformLocation(_glProgram, "image2"), 3);
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
    glActiveTexture(GL_TEXTURE4);
    glGenTextures(1, &_texture4);
    glBindTexture(GL_TEXTURE_2D, _texture4);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture4, 0);
}

#pragma mark - public

- (void)render {
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, _width, _height);
    glDrawArrays(GL_TRIANGLES, 0, 6);
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
