
/* So here we want to load up the game engine emma,
 set window size and we are good to go!
 =================================================== */


#import "app.h"
#import "EmmaView.h"
#import <WebKit/WebKit.h>

@implementation App

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType( &psn, kProcessTransformToUIElementApplication );
    [self configureWindow];
    // [self setupDirector];
}

- (void)configureWindow {

    // make translucent
    [self.window setOpaque:NO];
    NSColor *transparent = [NSColor colorWithCalibratedWhite:1.0 alpha:0.0];
    [self.window setBackgroundColor:transparent];
    CGRect frame = CGRectMake( 0, 0, 500, 500 );
    [self.window setFrame:frame display:YES];
    //[self.window setLevel:kCGFloatingWindowLevelKey];

    [self.window setStyleMask:NSBorderlessWindowMask];
    EmmaView *view =
        [[EmmaView alloc] initWithFrame:self.window.frame frameName:@"" groupName:@""];

    NSURL *url = [NSURL URLWithString:@"http://localhost:9000"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [[view mainFrame] loadRequest:urlRequest];
    [self.window setContentView:view];
    [self.window setIgnoresMouseEvents:YES];
    [view setDrawsBackground:NO];
    // = [UIColor clearColor];

    // todo reapply frame
    [self.window setLevel:kCGDesktopWindowLevelKey];
    [self.window setFrame:[[NSScreen mainScreen] frame] display:YES];
}

- (void)dealloc {
    [_emma release];
    [super dealloc];
}

@end