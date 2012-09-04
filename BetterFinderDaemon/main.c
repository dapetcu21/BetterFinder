//
//  main.c
//  BetterFinderDaemon
//
//  Created by Marius Petcu on 9/4/12.
//  Copyright (c) 2012 Marius Petcu. All rights reserved.
//

#include <syslog.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define bundlepath "/Contents/MacOS/BetterFinder"

int is_file(const char * fi)
{
    FILE * f = fopen(fi, "r");
    if (!f) return 0;
    fclose(f);
    return 1;
}

const char * path_to_exec()
{
    const char * p = "/Applications/BetterFinder.app" bundlepath;
    if (!is_file(p))
        p = "/Applications/Utilities/BetterFinder.app" bundlepath;
    if (!is_file(p))
    {
        FILE * f = popen("mdfind \"kMDItemCFBundleIdentifier == 'com.dapetcu21.BetterFinder' && kMDItemContentType == 'com.apple.application-bundle'\"", "r");
        char * s = (char*)malloc(1024);
        fgets(s, 1024 - strlen(bundlepath), f);
        fclose(f);
        size_t n = strlen(s);
        if (n && s[n-1]=='\n')
            n--;
        strcpy(s+n, bundlepath);
        p = s;
    }
    
    if (!is_file(p))
    {
        syslog(LOG_ERR, "Can't find path to BetterFinder");
        while(1)
            sleep(1000000);
    }
    return p;
}

int main(int argc, const char * argv[])
{
    const char * p = path_to_exec();
	syslog(LOG_NOTICE, "starting daemon %s", p);
    execl(p, p, "daemon", NULL);
	return 0;
}