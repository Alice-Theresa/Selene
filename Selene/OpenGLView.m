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

void dataProviderReleaseCallback (void *info, const void *data, size_t size);

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
        [self setupTexture];
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

- (void)setupTextureWithGLKit {
    NSError *error;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"IMG_0227" ofType:@"jpg"];
    _spriteTexture = [GLKTextureLoader textureWithContentsOfFile:filePath options:nil error:&error];
    _image = glGetUniformLocation(_glProgram, "image");
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(_spriteTexture.target, _spriteTexture.name);
    glUniform1i(_image, 0);
}

- (void)setupTexture {
    CGImageRef cg = [UIImage imageNamed:@"IMG_0227.jpg"].CGImage;
    CFDataRef dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(cg));
    GLubyte *imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
    
    GLuint texID;
    glGenTextures(1, &texID);
    glBindTexture(GL_TEXTURE_2D, texID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)CGImageGetWidth(cg), (int)CGImageGetHeight(cg), 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);

}

- (void)render {
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    glFinish();
    UIImage *image = [UIImage imageNamed:@"IMG_0227.jpg"];
    NSUInteger totalBytesForImage = image.size.width * image.size.height * 4;
    GLubyte *rawImagePixels = (GLubyte *)malloc(totalBytesForImage);
    glReadPixels(0, 0, (int)image.size.width, (int)image.size.height, GL_RGBA, GL_UNSIGNED_BYTE, rawImagePixels);
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL,
                                                                  rawImagePixels,
                                                                  totalBytesForImage,
                                                                  NULL);
    CGImageRef cgImageFromBytes = CGImageCreate((int)image.size.width,
                                                (int)image.size.height,
                                                8,
                                                32,
                                                4 * (int)image.size.width,
                                                CGColorSpaceCreateDeviceRGB(),
                                                kCGBitmapByteOrderDefault | kCGImageAlphaLast,
                                                dataProvider,
                                                NULL,
                                                YES,
                                                kCGRenderingIntentDefault);
    UIImage *finalImage = [UIImage imageWithCGImage:cgImageFromBytes];
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

void dataProviderReleaseCallback (void *info, const void *data, size_t size)
{
    free((void *)data);
}

@end
