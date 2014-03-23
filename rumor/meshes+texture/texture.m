//
// Created by ChrisAllen on 22/03/2014.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "texture.h"
#import <GLKit/GLKit.h>

@implementation texture

-(void)loadTexture:(NSString *) name{

    status = NULL;
    NSString *path = [[NSBundle mainBundle] pathForImageResource:name];
    self.textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:nil error:status];

}



@end