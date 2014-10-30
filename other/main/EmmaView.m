//
//  EmmaView.m
//  desky
//
//  Created by Chris Allen on 30/10/2014.
//  Copyright (c) 2014 Chris Allen. All rights reserved.
//

#import "EmmaView.h"

@implementation EmmaView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        // Initialization code here.
    }
    return self;
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self clearView];
}

- (void)clearView {
    [[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.0] set];
    NSRectFill( [self bounds] );
}

@end
