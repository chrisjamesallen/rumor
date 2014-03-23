//
// Created by ChrisAllen on 22/03/2014.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLKTextureInfo;


@interface texture : NSObject{
    NSError **status;
}
@property(nonatomic, retain) GLKTextureInfo *textureInfo;
@end