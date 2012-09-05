//
//  BFPrefPane.m
//  BetterFinder
//
//  Created by Marius Petcu on 9/5/12.
//  Copyright (c) 2012 Marius Petcu. All rights reserved.
//

#import "BFPrefPane.h"
#import "BetterFinder.h"

@interface BFPrefPane ()

@end

@implementation BFPrefPane

- (IBAction)uninstall:(id)sender
{
    const char * path = [[[[[BetterFinder sharedInstance] bundle] bundlePath] stringByAppendingString:@"/../../MacOS/BetterFinder"] fileSystemRepresentation];

    if (!fork())
    {
        execl(path, path, "uninstall", NULL);
        NSLog(@"execl: %s", strerror(errno));
    }
}

- (IBAction)restart:(id)sender
{
    exit(-1);
}

@end
