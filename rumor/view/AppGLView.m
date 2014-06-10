#import "AppGLView.h"
#import "Emma.h"

// c callbacks
// This is the callback function for the display link.
static CVReturn OpenGLViewCoreProfileCallBack( CVDisplayLinkRef displayLink,
                                               const CVTimeStamp *now,
                                               const CVTimeStamp *outputTime,
                                               CVOptionFlags flagsIn,
                                               CVOptionFlags *flagsOut,
                                               void *displayLinkContext ) {
    
    @autoreleasepool {
        AppGLView *view = (__bridge AppGLView *)displayLinkContext;
        [view.openGLContext makeCurrentContext];
        CGLLockContext(view.openGLContext.CGLContextObj ); // This is needed because
                                                // this isn't running on
                                                // the main thread.
        //call lua
         emma_update(L);
         emma_draw(L);
        [view draw:view.bounds]; // Draw the scene. This doesn't need to be in
        // the drawRect method.
        CGLUnlockContext( view.openGLContext.CGLContextObj );
        CGLFlushDrawable( view.openGLContext.CGLContextObj ); // This does glFlush() for you.
        return kCVReturnSuccess;
    }
}


/* : AppGLView
 =================================================== */
@interface AppGLView () {
    CVDisplayLinkRef *dL;
}
@property( atomic, assign ) CVDisplayLinkRef *displayLink;
@end

@implementation AppGLView

- (void)setup {

    NSLog( @"setup app gl view" );
    // var
    int aValue = 0;
    NSOpenGLPixelFormat *format;
    NSOpenGLContext *context;

    NSOpenGLPixelFormatAttribute pixelFormats[] = {
        NSOpenGLPFAColorSize,     32,
        NSOpenGLPFADepthSize,     32,
        NSOpenGLPFADoubleBuffer,  NSOpenGLPFAStencilSize,
        8,                        NSOpenGLPFAAccelerated,
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        0
    };
    format = [[[NSOpenGLPixelFormat alloc]
        initWithAttributes:pixelFormats] autorelease];
    context = [[[NSOpenGLContext alloc] initWithFormat:format
                                          shareContext:nil] autorelease];
    [context setValues:&aValue forParameter:NSOpenGLCPSurfaceOpacity];

    [self setOpenGLContext:context];
    [self setPixelFormat:format];
    [self.openGLContext makeCurrentContext];
}

- (void)draw:(NSRect)dirtyRect {
    //[self clearView];
    [self.director draw];
    //we need to call lua here
    
    //grab global main and call update
    
}

// note: important to remember
// [NSGraphicsContext currentContext]; (the window context, what we need
// here to make window translucent)
// [NSOpenGLContext currentContext]; (the opengl context, what we use to
// draw our own stuff)

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self clearView];
}

- (void)reshape {
    NSLog( @"reshape" );
    glViewport( 0, 0, windowSize.width, windowSize.height );
}

- (void)mouseUp:(NSEvent *)theEvent {
    NSLog( @"mouseup" );
    [self.openGLContext flushBuffer];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
    windowSize = frameSize;
    self.frame = CGRectMake( 0, 0, frameSize.width, frameSize.height );
    return frameSize;
}

- (void)clearView {
    [[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.0] set];
    NSRectFill( [self bounds] );
}

- (void)prepareOpenGL {
    [super prepareOpenGL];
    NSLog( @"prepareOpenGL >>> version %s", glGetString( GL_VERSION ) );
    [self clearView];
    glEnable( GL_BLEND );
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    glClear( GL_COLOR_BUFFER_BIT );
    glFlush();
    [self.director start];
    [self startDrawLoop];
    
 
    
}

- (void)startDrawLoop {

    GLint swapInt = 1;
    [self.openGLContext setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];

    // Below creates the display link and tell it what function to call when it
    // needs to draw a frame.
    CVDisplayLinkCreateWithActiveCGDisplays( &_displayLink );

    // set callback function
    CVDisplayLinkSetOutputCallback( _displayLink,
                                    &OpenGLViewCoreProfileCallBack, self );

    //
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(
        _displayLink, self.openGLContext.CGLContextObj,
        self.pixelFormat.CGLPixelFormatObj );

    // lets fire it up!
    CVDisplayLinkStart( _displayLink );
}

- (void)stopDrawLoop {
}

- (void)dealloc {
    [_director release];
    [super dealloc];
}

@end