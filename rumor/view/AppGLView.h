//
// Created by ChrisAllen on 22/03/2014.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/OpenGL.h>
#import <GLKit/GLKit.h>
#import <QuartzCore/CVDisplayLink.h>

@class director;

@interface AppGLView : NSOpenGLView <NSWindowDelegate>{
@public
    NSSize  windowSize;
}
@property(nonatomic, retain) director *director;

- (void)setup;
@end