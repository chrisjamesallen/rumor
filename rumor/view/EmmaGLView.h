//
// Created by ChrisAllen on 22/03/2014.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/OpenGL.h>
#import <GLKit/GLKit.h>
#import <QuartzCore/CVDisplayLink.h>

@class Emma;

@interface EmmaGLView : NSOpenGLView <NSWindowDelegate> {
  @public
    NSSize windowSize;
    NSCondition* condition;
}
@property( nonatomic, retain ) Emma* director;

- (void)setup;
- (void)stopDrawLoop;
@end

BOOL FLUSHING;