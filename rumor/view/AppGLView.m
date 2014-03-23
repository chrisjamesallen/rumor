//
// Created by ChrisAllen on 22/03/2014.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppGLView.h"#import "director.h"


@implementation AppGLView


// start drawing stuff
// for that i need set context, pixel format, set core profile

- (void)drawRect:(NSRect)bounds {
    NSLog(@"draw rect") ;
	[self clearContent];
    glViewport(0,0, windowSize.width, windowSize.height);
	glEnable (GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //glColorMask(FALSE, FALSE, FALSE, TRUE);//This ensures that only alpha will be effected
    glClearColor(0, 0, 0, 0.0);//alphaValue - Value to which you need to clear
    glClear(GL_COLOR_BUFFER_BIT);
   //
    glFlush();
}

- (void)clearContent
{
	[[NSColor colorWithCalibratedRed: 0.01 green: 0.01 blue: 0.4 alpha:0.4] set];
	//[[NSColor colorWithCalibratedRed: 0.00 green: 0.00 blue: 0.0 alpha:0.4] set];
	NSRectFill([self bounds]);
}

- (void) setup {
    NSLog(@"setup app gl view");
    // create a new pixel format?
    NSOpenGLPixelFormatAttribute pixelFormats[] = {
            NSOpenGLPFAColorSize, 32,
            NSOpenGLPFADepthSize, 32,
			NSOpenGLPFADoubleBuffer,
            NSOpenGLPFAStencilSize, 8,
            NSOpenGLPFAAccelerated,
            NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
            0

    };

    NSOpenGLPixelFormat * format = [[[NSOpenGLPixelFormat alloc] initWithAttributes: pixelFormats] autorelease];
    NSOpenGLContext * context = [[[NSOpenGLContext alloc] initWithFormat:format shareContext:nil] autorelease];
    int aValue = 0;
    [context setValues:&aValue forParameter:NSOpenGLCPSurfaceOpacity];
	[[self window] setOpaque:NO];

    [self setOpenGLContext:context];
   [self.openGLContext makeCurrentContext];
}


- (void) reshape {
    NSLog(@"reshape");
    glViewport(0,0, windowSize.width, windowSize.height);
}

-(NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize{
    windowSize = frameSize;
    self.frame = CGRectMake(0, 0, frameSize.width, frameSize.height);
    return frameSize;
}

- (void)prepareOpenGL {
    NSLog(@"prepareOpenGL >>> version %s", glGetString(GL_VERSION));
   // glEnable(GL_BLEND);
//	glClearColor(1.0, 1.0, 0.0, 1.0);//alphaValue - Value to which you need to clear
//	glClear(GL_COLOR_BUFFER_BIT);
//	glFlush();
}


- (void)mouseUp:(NSEvent *)theEvent{
    NSLog(@"mouseup");

	[self.director start];
	//glClearColor(1.0, 1.0, 0.0, 1.0);//alphaValue - Value to which you need to clear
	//glClear(GL_COLOR_BUFFER_BIT);
	//glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	[self.openGLContext flushBuffer];
	//glFlush();

}

- (void)dealloc {
    [_director release];
    [super dealloc];
}


@end