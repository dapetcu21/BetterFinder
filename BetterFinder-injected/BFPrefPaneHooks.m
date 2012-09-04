//
//  BetterFinder+BFPrefPaneHooks.m
//  BetterFinder
//
//  Created by Marius Petcu on 9/4/12.
//  Copyright (c) 2012 Marius Petcu. All rights reserved.
//

#import "BFPrefPaneHooks.h"

@implementation BetterFinder (BFPrefPaneHooks)

BFDefineMethod(id, TPreferencesWindowController, controllerForPaneAtIndex, long long index)
{
    id ret = controllerForPaneAtIndex_orig(self, _cmd, index);
    NSLog(@"meow %@ %lld", ret, index);
    return ret;
}

-(void)injectPrefPane
{
    BFReplaceMethod(TPreferencesWindowController$, @selector(controllerForPaneAtIndex:), "v@:q", controllerForPaneAtIndex);
}

@end
