//
//  OpenGLView.m
//  Selene
//
//  Created by Theresa on 2017/12/7.
//  Copyright © 2017年 Theresa. All rights reserved.
//

#import <OpenGLES/ES3/gl.h>
#import "OpenGLView.h"

@implementation OpenGLView {
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupLayer];
        [self setupContext];
        [self setupBuffer];
        [self render];
    }
    return self;
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
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

- (void)render {
    glClearColor(1.0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
