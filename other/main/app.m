
/* So here we want to load up the game engine emma,
 set window size and we are good to go!
 =================================================== */


#import "app.h"
#import "AppGLView.h"
#import "Emma.h"
#import <WebKit/WebKit.h>

@implementation App

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self configureWindow];
   // [self setupDirector];
}

- (void)configureWindow {

    // make translucent
    [self.window setOpaque:NO];
    NSColor *transparent = [NSColor colorWithCalibratedWhite:1.0 alpha:0.0];
    [self.window setBackgroundColor:transparent];
    // frame = CGRectMake( 0, 0, 500, 500 );
    //[self.window setFrame:frame display:YES];
    [self.window setLevel:kCGFloatingWindowLevelKey];
    
    
    WebView * view = [[WebView alloc] initWithFrame: self.window.frame frameName:@"" groupName:@""];
    
    NSURL *url = [NSURL URLWithString:@"http://localhost:3000"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [[view mainFrame] loadRequest:urlRequest];
    [self.window setContentView:view];
    [self.window setIgnoresMouseEvents:YES];
    [view setDrawsBackground:NO];
    // = [UIColor clearColor];
    
    
    // todo reapply frame
    [self.window setLevel:kCGDesktopWindowLevelKey];
   //[self.window setFrame:[[NSScreen mainScreen] frame] display:YES];
}

- (void)setupDirector {

    // vars
    NSWindow *window = self.window;

    // create glview
    self.glview = [[AppGLView alloc] initWithFrame:self.window.frame];
    [self.glview setup];

    // add to window
    window.delegate = self.glview;
    [window setContentView:self.glview];

    // set view dimensions
    self.glview->windowSize = window.frame.size;

    // create Emma
    self.emma = [[[Emma alloc] init] autorelease];
    self.emma->view = self.glview;
    // assign emma to view
    self.glview.director = self.emma;

    // start emma
    //[self.emma start];
}

- (void)dealloc {
    [_emma release];
    [super dealloc];
}

@end