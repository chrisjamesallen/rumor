//
// Created by ChrisAllen on 22/03/2014.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class renderer;


@interface mesh : NSObject{
    GLKMatrix4 modelview;
	GLuint vertex_vbo, vertex_array;
}
@property(nonatomic, retain) renderer * renderer;

- (void)draw;

- (void)assignRender:(renderer *)render;

- (void)translate;

- (void)scale;
@end