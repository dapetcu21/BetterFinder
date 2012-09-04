//
//  main.m
//  BetterFinder
//
//  Created by Marius Petcu on 9/3/12.
//  Copyright (c) 2012 Marius Petcu. All rights reserved.
//

#include <Cocoa/Cocoa.h>
#include <mach_inject_bundle/mach_inject_bundle.h>

int betterfinder_uninstall();

pid_t finder_pid(uid_t uid)
{
    char s[32];
    sprintf(s, "/bin/ps -axU%lld", (long long)uid);
    FILE * f = popen(s, "r");
    
    long long pid;
    char line[512];
    fgets(line, 512, f); //read ps's header
    while(fgets(line, 512, f))
    {
        if (sscanf(line, "%lld", &pid) != 1)
            continue;
        if (strstr(line, "/System/Library/CoreServices/Finder.app/Contents/MacOS/Finder"))
            return (pid_t)pid;
    }
    fclose(f);
    return 0;
}

void inject(uid_t uid)
{
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BetterFinder-injected"
                                                            ofType:@"bundle"];
    const char * path = [bundlePath fileSystemRepresentation];
 
    pid_t pid = finder_pid(uid);
    if (!pid)
    {
        NSLog(@"Can't get Finder's pid for the current user (%lld)", (long long)uid);
        return;
    }
    
    if ([NSConnection rootProxyForConnectionWithRegisteredName:
            [NSString stringWithFormat:@"BetterFinder-inst-%lld", (long long)pid]
                                                          host:nil])
    {
        NSLog(@"BetterFinder is already injected in Finder (PID %lld)", (long long)pid);
        return;
    }
    
    NSLog(@"Injecting BetterFinder in Finder (PID %lld)", (long long)pid);
    if (mach_inject_bundle_pid(path, pid))
        NSLog(@"Couldn't inject BetterFinder into Finder");
}

@interface BFDaemonRoot : NSObject
-(void)inject:(uid_t)uid;
@end

@implementation BFDaemonRoot
-(void)inject:(uid_t)uid
{
    inject(uid);
}
@end

int injector_daemon()
{
    NSLog(@"daemon started");
    NSRunLoop * loop = [NSRunLoop currentRunLoop];
    NSConnection * conn = [NSConnection new];
    BFDaemonRoot * root = [BFDaemonRoot new];
    [conn registerName:@"BetterFinder"];
    [conn setRootObject:root];
    [conn addRunLoop:loop];
    [loop run];
    [conn release];
    [root release];
    [loop release];
    return 0;
}

int injector_client()
{
    BFDaemonRoot * root = (BFDaemonRoot*)[NSConnection rootProxyForConnectionWithRegisteredName:@"BetterFinder" host:nil];
    [root inject:getuid()];
    return 0;
}

int daemon_running = 0;
int daemon_installed = 0;

int injector_installed()
{
    daemon_running = [NSConnection rootProxyForConnectionWithRegisteredName:@"BetterFinder" host:nil]!=nil;
    daemon_installed = [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/PrivilegedHelperTools/com.dapetcu21.BetterFinderDaemon"];
    return daemon_installed && daemon_running;
}

int main(int argc, char *argv[])
{
    @autoreleasepool {
        if ((argc > 1) &&(!strcmp(argv[1], "daemon")))
                return injector_daemon();
        if ((argc > 1) &&(!strcmp(argv[1], "uninstall")))
        {
            if (!betterfinder_uninstall())
            {
                pid_t pid = finder_pid(getuid());
                if (pid>0)
                    kill(pid, SIGKILL);
                return 0;
            }
            return 1;
        }
        if (!injector_installed())
            return NSApplicationMain(argc, (const char**)argv);
        return injector_client();
    }
}
