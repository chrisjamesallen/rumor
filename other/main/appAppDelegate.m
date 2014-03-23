//
//  appAppDelegate.m
//  rumor
//
//  Created by ChrisAllen on 22/03/2014.
//  Copyright (c) 2014 ChrisAllen. All rights reserved.
//

#import "appAppDelegate.h"
#import "AppGLView.h"
#import "director.h"

@implementation appAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSWindow * window = self.window;

    // make a view...
    self.glview = [[AppGLView alloc] initWithFrame: CGRectMake(0,0,512,512)];
    [self.glview setup];
    window.delegate = self.glview;

    // make window transparent
    [window setOpaque:NO];
    NSColor * transparent = [NSColor colorWithCalibratedWhite:1.0 alpha:0.4];
    [window setBackgroundColor:transparent];
    
    //add view to window
//    [window.contentView addSubview:self.glview];
	[window setContentView:self.glview];
    self.glview->windowSize =  window.frame.size;
	self.glview.frame = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);

    //prepare view opengl.. :)
    //[self.glview prepareOpenGL];

    //create director
    self.director = [[[director alloc]init] autorelease];

    //start director :)
    //[self.director start];

    self.glview.director = self.director;
    //Make full screen dimensions..
    //CGRect frame = [NSScreen mainScreen].frame;
    //[window setFrame: frame display:YES];


/*
* TODO
* learn screen methods
* */




}

- (void)dealloc {
    [_director release];
    [super dealloc];
}


@end