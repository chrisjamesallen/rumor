//
//  appAppDelegate.h
//  rumor
//
//  Created by ChrisAllen on 22/03/2014.
//  Copyright (c) 2014 ChrisAllen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AppGLView;
@class Emma;

@interface App : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property(nonatomic, retain) AppGLView *glview;
@property(nonatomic, retain) Emma *emma;
@end