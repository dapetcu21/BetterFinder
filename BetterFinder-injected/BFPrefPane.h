//
//  BFPrefPane.h
//  BetterFinder
//
//  Created by Marius Petcu on 9/5/12.
//  Copyright (c) 2012 Marius Petcu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Finder/TPaneController.h"

@interface BFPrefPane : NSViewController
{
    //TViewController
    BOOL _callingLoadView;
    BOOL _loadingFromNib;
    BOOL _isViewLoaded;
    
    //TPaneController
    NSWindow *_window;
    
    //mine
}

@end
