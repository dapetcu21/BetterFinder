//
//  BetterFinder+BFPrefPaneHooks.m
//  BetterFinder
//
//  Created by Marius Petcu on 9/4/12.
//  Copyright (c) 2012 Marius Petcu. All rights reserved.
//

#import "BFPrefPaneHooks.h"
#import "BFPrefPane.h"
#import "Finder/TPreferencesWindowController.h"
#define TOOLBARID @"com.dapetcu21.BetterFinderPrefs"

@interface BFToolbarItem : NSToolbarItem //Ugly hack but works best
@end
@implementation BFToolbarItem
-(void)setImage:(NSImage*)img
{
    if (img)
        img = [[BetterFinder sharedInstance] toolbarItemImage];
    [super setImage:img];
}
@end

@implementation BetterFinder (BFPrefPaneHooks)

-(BFPrefPane*)prefPane
{
    if (!pane)
    {
        pane = [[BFPrefPane alloc] initWithNibName:@"BFPrefPane" bundle:[self bundle]];
        [[pane view] setHidden:YES];
    }
    return pane;
}

BFDefineMethod(id, TPreferencesWindowController, TPWCcontrollerForPaneAtIndex, long long index)
{
    id ret = TPWCcontrollerForPaneAtIndex_orig(self, _cmd, index);
    if (index == 4)
        ret = [[BetterFinder sharedInstance] prefPane];
    return ret;
}

-(void)bfButton:(id)sender
{
    [[TPreferencesWindowController$ instance] selectPaneAtIndex:4];
}

-(NSArray*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return [self toolbarOrder];
}


-(NSArray*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return [self toolbarOrder];
}

-(NSArray*)toolbarSelectableItemIdentifiers:(NSToolbar*)toolbar
{
    TPreferencesWindowController *c = [TPreferencesWindowController$ instance];
    if ([c respondsToSelector:@selector(toolbarSelectableItemIdentifiers:)])
        return [[c toolbarSelectableItemIdentifiers:toolbar] arrayByAddingObject:TOOLBARID];
    else
        return [self toolbarOrder];
}

-(NSToolbarItem*)toolbarItem
{
    if (!toolItem)
    {
        toolItem = [[BFToolbarItem alloc] initWithItemIdentifier:TOOLBARID];
        [toolItem setLabel:@"BetterFinder"];
        [toolItem setImage:[self toolbarItemImage]];
        [toolItem setTarget:self];
        [toolItem setAction:@selector(bfButton:)];
    }
    return toolItem;
}

-(NSImage*)toolbarItemImage
{
    if (!toolItemImage)
        toolItemImage = [[NSImage alloc] initWithContentsOfFile:[[self bundle] pathForResource:@"icon" ofType:@"png"]];
    return toolItemImage;
}


-(NSToolbarItem*)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemID willBeInsertedIntoToolbar:(BOOL)willBeInserted
{
    return [[self toolbarItems] objectForKey:itemID];
}

-(NSArray*)toolbarOrder
{
    return toolbarOrder;
}

-(NSDictionary*)toolbarItems
{
    return toolbarItems;
}

-(void)reconfigureToolbarInController:(TPreferencesWindowController*)controller
{
    
    NSToolbar ** _toolbar = &BFIvar(NSToolbar *, controller, "_toolbar");
    NSToolbar * toolbar = *_toolbar;
    
    if (!toolbar) return;
    
    NSArray * items = toolbar.items;
    [toolbarItems release];
    toolbarItems = [[NSMutableDictionary alloc] initWithCapacity:[items count]+1];
    [toolbarOrder release];
    toolbarOrder = [[NSMutableArray alloc] initWithCapacity:[items count]+1];
    for (NSToolbarItem * item in items)
    {
        NSString * ide = [item itemIdentifier];
        [toolbarItems setObject:item forKey:ide];
        [toolbarOrder addObject:ide];
    }
    [toolbarItems setObject:[self toolbarItem] forKey:TOOLBARID];
    [toolbarOrder addObject:TOOLBARID];
    
    
    NSToolbar * tb = [[[NSToolbar alloc] initWithIdentifier:[toolbar identifier]] autorelease];
    [tb setDisplayMode:toolbar.displayMode];
    [tb setSizeMode:toolbar.sizeMode];
    [tb setAllowsUserCustomization:toolbar.allowsUserCustomization];
    [tb setAutosavesConfiguration:toolbar.autosavesConfiguration];
    [tb setShowsBaselineSeparator:toolbar.showsBaselineSeparator];
    
    (*_toolbar) = toolbar = tb;
    [[controller window] setToolbar:toolbar];
    
    toolbar.delegate = (NSObject<NSToolbarDelegate>*)self;
    
    int i = 0;
    for (NSString * str in toolbarOrder)
        [toolbar insertItemWithItemIdentifier:str atIndex:i++];
    
    [[[controller window] contentView] addSubview:[[self prefPane] view]];
    
}

BFDefineMethod(void, TPreferencesWindowController, TPWCawakeFromNib)
{
    [[BetterFinder sharedInstance] reconfigureToolbarInController:self];
    if (TPWCawakeFromNib_orig)
        TPWCawakeFromNib_orig(self, _cmd);
}

-(void)injectPrefPane
{
    BFReplaceMethod(TPreferencesWindowController$, controllerForPaneAtIndex:, "v@:q", TPWCcontrollerForPaneAtIndex);
    BFReplaceMethod(TPreferencesWindowController$, windowDidLoad, "v@:", TPWCawakeFromNib);
    
    BFSoftSubclass("BFPrefPane", "TViewController");
    BFSoftSubclass("BFPrefPane", "TPaneController");
    
    [self reconfigureToolbarInController:[TPreferencesWindowController$ instance]];
}

-(void)releasePrefPane
{
    [toolbarItems release];
    toolbarItems = nil;
    [toolbarOrder release];
    toolbarOrder = nil;
    [toolItem release];
    toolItem = nil;
    [toolItemImage release];
    toolItemImage = nil;
    [pane release];
    pane = nil;
}

@end
