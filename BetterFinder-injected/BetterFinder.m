//
//  BetterFinder.m
//  BetterFinder
//
//  Created by Marius Petcu on 9/3/12.
//  Copyright (c) 2012 Marius Petcu. All rights reserved.
//

#import "BetterFinder.h"

@implementation BetterFinder

-(id)init
{
    if ((self = [super init]))
    {
        conn = [NSConnection new];
        [conn setRootObject:self];
        [conn registerName:[NSString stringWithFormat:@"BetterFinder-inst-%lld", (long long)getpid()]];
        [conn addRunLoop:[NSRunLoop currentRunLoop]];
        
        NSLog(@"WE ARE IN UR BASE");
    }
    return self;
}

-(void)dealloc
{
    [conn release];
    [super dealloc];
}

+(BetterFinder*) sharedInstance
{
    static BetterFinder * bf = nil;
    if (!bf)
        bf = [BetterFinder new];
    return bf;
}

+(void)load
{
    [BetterFinder sharedInstance];
}

@end
