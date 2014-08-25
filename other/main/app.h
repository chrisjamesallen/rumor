//
//  appAppDelegate.h
//  rumor
//
//  Created by ChrisAllen on 22/03/2014.
//  Copyright (c) 2014 ChrisAllen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EmmaGLView;
@class Emma;

@interface App : NSObject <NSApplicationDelegate> {
    CGRect frame;
}

@property( assign ) IBOutlet NSWindow *window;

@property( nonatomic, retain ) EmmaGLView *glview;
@property( nonatomic, retain ) Emma *emma;
@end