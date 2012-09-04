//
//  AppDelegate.h
//  meow
//
//  Created by Marius Petcu on 9/4/12.
//  Copyright (c) 2012 Marius Petcu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *textField;

-(IBAction)install:(id)sender;

@end

extern int daemon_running;
extern int daemon_installed;

int injector_client();