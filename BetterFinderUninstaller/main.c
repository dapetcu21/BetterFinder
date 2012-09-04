//
//  main.c
//  BetterFinderUninstaller
//
//  Created by Marius Petcu on 9/4/12.
//  Copyright (c) 2012 Marius Petcu. All rights reserved.
//

#include <stdio.h>
#include <syslog.h>

int main(int argc, const char * argv[])
{
    syslog(LOG_NOTICE, "Started BetterFinder Uninstaller");
    system("launchctl unload /Library/LaunchDaemons/com.dapetcu21.BetterFinderDaemon.plist");
    system("rm -f /Library/LaunchDaemons/com.dapetcu21.BetterFinderDaemon.plist");
    system("rm -f /Library/LaunchDaemons/com.dapetcu21.BetterFinderUninstaller.plist");
    system("rm -f /Library/PrivilegedHelperTools/com.dapetcu21.BetterFinderDaemon");
    system("rm -f /Library/PrivilegedHelperTools/com.dapetcu21.BetterFinderUninstaller");
    return 0;
}

