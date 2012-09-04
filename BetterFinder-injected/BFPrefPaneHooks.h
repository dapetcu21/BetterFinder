//
//  BetterFinder+BFPrefPaneHooks.h
//  BetterFinder
//
//  Created by Marius Petcu on 9/4/12.
//  Copyright (c) 2012 Marius Petcu. All rights reserved.
//

#import "BetterFinder.h"

@interface BetterFinder (BFPrefPaneHooks)
-(void)injectPrefPane;
-(void)releasePrefPane;
-(NSArray*)toolbarOrder;
-(NSDictionary*)toolbarItems;
-(BFPrefPane*)prefPane;
@end
