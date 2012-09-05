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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)uninstall:(id)sender
{
    const char * path = [[[[[BetterFinder sharedInstance] bundle] bundlePath] stringByAppendingString:@"/../../MacOS/BetterFinder"] fileSystemRepresentation];
    if (!fork())
        execl(path, path, "uninstall", NULL);
    exit(-1);
}

@end
