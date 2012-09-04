//
//  AppDelegate.m
//  meow
//
//  Created by Marius Petcu on 9/4/12.
//  Copyright (c) 2012 Marius Petcu. All rights reserved.
//

#import "AppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>
#import <Security/Authorization.h>


@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if (daemon_installed)
    {
        [self.textField setStringValue:@"Oops. BetterFinder seems to be installed but the daemon is not running. Reinstalling won't hurt"];
        NSRect r = self.window.frame;
        r.origin.y += (r.size.height - 130)/2;
        r.size.height = 130;
        [self.window setFrame:r display:YES animate:NO];
    }
    [self.window setDelegate:self];
}

- (void)windowWillClose:(NSNotification *)aNotification {
    [NSApp terminate:self];
}

int betterfinder_install()
{
	int result = 1;
    
	AuthorizationItem authItem		= { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
	AuthorizationRights authRights	= { 1, &authItem };
	AuthorizationFlags flags		=	kAuthorizationFlagDefaults				|
    kAuthorizationFlagInteractionAllowed	|
    kAuthorizationFlagPreAuthorize			|
    kAuthorizationFlagExtendRights;
    
	AuthorizationRef authRef = NULL;
	
	OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &authRef);
	if (status != errAuthorizationSuccess) {
		NSLog(@"Failed to create AuthorizationRef, return code %i", status);
	} else {
		result = !SMJobBless(kSMDomainSystemLaunchd, (CFStringRef)@"com.dapetcu21.BetterFinderDaemon", authRef, NULL);
	}
	
	return result;
}

int betterfinder_uninstall()
{
	int result = 1;
    
	AuthorizationItem authItem		= { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
	AuthorizationRights authRights	= { 1, &authItem };
	AuthorizationFlags flags		=	kAuthorizationFlagDefaults				|
    kAuthorizationFlagInteractionAllowed	|
    kAuthorizationFlagPreAuthorize			|
    kAuthorizationFlagExtendRights;
    
	AuthorizationRef authRef = NULL;
	
	OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &authRef);
	if (status != errAuthorizationSuccess) {
		NSLog(@"Failed to create AuthorizationRef, return code %i", status);
	} else {
		result = !SMJobRemove(kSMDomainSystemLaunchd, (CFStringRef)@"com.dapetcu21.BetterFinderDaemon", authRef, 1, NULL);
	}
    
	return result;
}

-(IBAction)install:(id)sender
{
    betterfinder_install();
    sleep(2);
    injector_client();
    [NSApp terminate:self];
}

@end
