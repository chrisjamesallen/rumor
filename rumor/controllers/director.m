//
// Created by ChrisAllen on 22/03/2014.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "director.h"
#import "foo.h"


@implementation director{
    foo * test;
}

-(id) init;
{
    self = [super init];
    if(self != nil)
    {
	test = [[foo alloc] init];
    }
    return self;
}

-(void)test{
    //create fooObject

    

    [test draw];


    //create mesh
    //create renderer
}



- (void)start {
    [self test];

}
@end