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
    NSLog(@"selectable");
    TPreferencesWindowController *c = [TPreferencesWindowController$ instance];
    if ([c respondsToSelector:@selector(toolbarSelectableItemIdentifiers:)])
        return [[c toolbarSelectableItemIdentifiers:toolbar] arrayByAddingObject:TOOLBARID];
    else
        return [self toolbarOrder];
}

-(NSToolbarItem*)toolbarItem
{
    NSToolbarItem * toolitem = [[[NSToolbarItem alloc] initWithItemIdentifier:TOOLBARID] autorelease];
    [toolitem setLabel:@"BetterFinder"];
    NSImage * img = [[NSImage alloc] initWithContentsOfFile:[[self bundle] pathForResource:@"icon" ofType:@"png"]];
    [toolitem setImage:img];
    [toolitem setTarget:self];
    [toolitem setAction:@selector(bfButton:)];
    [img release];
    return toolitem;
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
    
    NSLog(@"reconfigured");
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
    NSUInteger ix = [toolbarOrder indexOfObject:[toolbar selectedItemIdentifier]];
    if (ix == NSNotFound)
        ix = 0;
    
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
    NSLog(@"awakeFromNib");
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
    NSLog(@"release");
    [toolbarItems release];
    toolbarItems = nil;
    [toolbarOrder release];
    toolbarOrder = nil;
    [pane release];
    pane = nil;
}

@end
