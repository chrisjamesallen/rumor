
/* So here we want to load up the game engine emma,
 set window size and we are good to go!
 =================================================== */

#import "app.h"
#import "AppGLView.h"
#import "Emma.h"

@implementation App

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [self configureWindow];
  [self setupDirector];
}

- (void)configureWindow {

  // make translucent
  [self.window setOpaque:NO];
  NSColor *transparent = [NSColor colorWithCalibratedWhite:1.0 alpha:0.4];
  [self.window setBackgroundColor:transparent];
}

- (void)setupDirector {

  // vars
  NSWindow *window = self.window;

  // create glview
  self.glview = [[AppGLView alloc] initWithFrame:CGRectMake(0, 0, 512, 512)];
  [self.glview setup];

  // add to window
  window.delegate = self.glview;
  [window setContentView:self.glview];

  // set view dimensions
  self.glview->windowSize = window.frame.size;
  self.glview.frame =
      CGRectMake(300, 0, window.frame.size.width, window.frame.size.height);

  // create Emma
  self.emma = [[[Emma alloc] init] autorelease];

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