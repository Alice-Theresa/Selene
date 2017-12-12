//
//  OpenGLView.m
//  Selene
//
//  Created by Theresa on 2017/12/7.
//  Copyright © 2017年 Theresa. All rights reserved.
//

#import <GLKit/GLKTextureLoader.h>
#import <OpenGLES/ES3/gl.h>
#import "OpenGLView.h"
#import "ShaderOperation.h"

@implementation OpenGLView {
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    
    GLuint _glProgram;
    GLuint _positionSlot; 
    GLuint _colorSlot;
    
    GLKTextureInfo *_spriteTexture;
    GLint _image;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupLayer];
        [self setupContext];
        [self setupBuffer];
        [self setupGLProgram];
        [self setupVBO];
        [self setupTexure];
        [self render];
    }
    return self;
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
    _eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking : @NO, kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8 };
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

- (void)setupBuffer {
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glDeleteFramebuffers(1, &_frameBuffer);
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)setupGLProgram {
    _glProgram = [ShaderOperation compileVertex:@"vert" fragment:@"frag"];
    glUseProgram(_glProgram);
    _positionSlot = glGetAttribLocation(_glProgram, "position");
    _colorSlot = glGetAttribLocation(_glProgram, "texcoord");
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
    
    glVertexAttribPointer(_colorSlot, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL + sizeof(GL_FLOAT) * 3);
    glEnableVertexAttribArray(_colorSlot);
}

- (void)setupTexure {
    NSError *error;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"IMG_0227" ofType:@"jpg"];
    _spriteTexture = [GLKTextureLoader textureWithContentsOfFile:filePath options:nil error:&error];
    _image = glGetUniformLocation(_glProgram, "image");
}

- (void)render {
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(_spriteTexture.target, _spriteTexture.name);
    glUniform1i(_image, 0);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
