#import "EmmaGLView.h"
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
        EmmaGLView *view = (__bridge EmmaGLView *)displayLinkContext;
        //[view->condition lock];

        if ( FLUSHING == NO && !fucked ) {
            [view.openGLContext makeCurrentContext];
            emma_update( L, outputTime->rateScalar, outputTime->videoTime );
            emma_draw( L );
            [view draw:view.bounds];
            CGLFlushDrawable( view.openGLContext.CGLContextObj );
        }

        //[view->condition unlock];
        return kCVReturnSuccess;
    }
}


/* : AppGLView
 =================================================== */
@interface EmmaGLView () {
    CVDisplayLinkRef *dL;
}
@property( atomic, assign ) CVDisplayLinkRef *displayLink;
@end

@implementation EmmaGLView

- (void)setup {
    int aValue;
    NSOpenGLPixelFormat *format;
    NSOpenGLContext *context;

    // Set pixel format
    NSOpenGLPixelFormatAttribute pixelFormats[] = {
        NSOpenGLPFAColorSize,          32,                      NSOpenGLPFADepthSize,
        32,                            NSOpenGLPFADoubleBuffer, NSOpenGLPFAStencilSize,
        8,                             NSOpenGLPFAAccelerated,  NSOpenGLPFAOpenGLProfile,
        NSOpenGLProfileVersion3_2Core, 0
    };
    format = [[[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormats] autorelease];
    [self setPixelFormat:format];

    // Set context
    aValue = 0;
    context =
        [[[NSOpenGLContext alloc] initWithFormat:format shareContext:nil] autorelease];
    [context setValues:&aValue forParameter:NSOpenGLCPSurfaceOpacity];
    [self setOpenGLContext:context];
    [self.openGLContext makeCurrentContext];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self clearView];
}

- (void)clearView {
    [[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.0] set];
    NSRectFill( [self bounds] );
}

- (void)prepareOpenGL {
    [super prepareOpenGL];
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
    CVDisplayLinkSetOutputCallback( _displayLink, &OpenGLViewCoreProfileCallBack, self );

    //
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(
        _displayLink, self.openGLContext.CGLContextObj,
        self.pixelFormat.CGLPixelFormatObj );

    // lets fire it up!
    CVDisplayLinkStart( _displayLink );
}

- (void)stopDrawLoop {
    CVDisplayLinkStop( _displayLink );
}


- (void)reshape {
}

- (void)mouseUp:(NSEvent *)theEvent {
    NSLog( @"mouseup" );
    [self.openGLContext flushBuffer];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
    return frameSize;
}


- (void)dealloc {
    [_director release];
    [super dealloc];
}

// note: important to remember
// [NSGraphicsContext currentContext]; (the window context, what we need
// here to make window translucent)
// [NSOpenGLContext currentContext]; (the opengl context, what we use to
// draw our own stuff)
@end