//
// Created by ChrisAllen on 22/03/2014.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "Emma.h"
#import "chris.h"


@implementation Emma {
    chris * test;
}

-(id) init;
{
    self = [super init];
    if(self != nil)
    {
	test = [[chris alloc] init];
    }
    return self;
}

-(void)test{
    [test draw];
}

- (void)start {
    [self test];
}
@end