//
// Created by ChrisAllen on 22/03/2014.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//
#import <GLKit/GLKit.h>
#import <OpenGL/OpenGL.h>
#import "chris.h"
 
#import "renderer.h"
 

@implementation chris

- (id)init {
    self = [super init];
    if (self) {
  
        self.renderer = [renderer default];
        [self.mesh assignRender:self.renderer];

    }

    return self;
}

-(void) draw{
    //do anything positional or change values here
 
}

-(void) update{

}


@end