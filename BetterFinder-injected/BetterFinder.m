//
//  BetterFinder.m
//  BetterFinder
//
//  Created by Marius Petcu on 9/3/12.
//  Copyright (c) 2012 Marius Petcu. All rights reserved.
//

#import "BetterFinder.h"
#import "BFPrefPaneHooks.h"

ptrdiff_t BFIvarOffset(Class c, const char * s)
{
    Ivar i = class_getInstanceVariable(c, s);
    return ivar_getOffset(i);
}

void * _BFIvar(id self, const char * s)
{
    Ivar i = class_getInstanceVariable([self class], s);
    return (void*)(((void*)(char*)self) + ivar_getOffset(i));
}

@implementation BetterFinder

-(void)loadClasses
{
    BFGetClass(TPreferencesWindowController);
}

-(void)injectMethods
{
    [self loadClasses];
    [self injectPrefPane];
}

-(NSBundle*)bundle
{
    return bundle;
}

#define bundlepath "/Contents/Resources/BetterFinder-injected.bundle"

BOOL is_file(const char * p)
{
    BOOL a,b;
    a = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:p] isDirectory:&b];
    return a&&b;
}

const char * path_to_bundle()
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
        p = NULL;
    return p;
}

-(id)init
{
    if ((self = [super init]))
    {
        conn = [NSConnection new];
        [conn setRootObject:self];
        [conn registerName:[NSString stringWithFormat:@"BetterFinder-inst-%lld", (long long)getpid()]];
        [conn addRunLoop:[NSRunLoop currentRunLoop]];
        
        const char * p = path_to_bundle();
        if (p)
            bundle = [[NSBundle bundleWithPath:[NSString stringWithUTF8String:p]] retain];
        if (!bundle)
            NSLog(@"Can't find path to BetterFinder");
        NSLog(@"WE ARE IN UR BASE: \"%s\"", p);
        
        [self injectMethods];
    }
    return self;
}

-(void)dealloc
{
    [self releasePrefPane];
    [conn release];
    [bundle release];
    [super dealloc];
}

+(BetterFinder*) sharedInstance
{
    static BetterFinder * bf = nil;
    if (!bf)
    {
        bf = [BetterFinder alloc];
        bf = [bf init];
    }
    return bf;
}

void BFSoftSubclass(const char * clss, const char * superclss)
{
    Class c = objc_getClass(clss);
    Class s = objc_getClass(superclss);
    
    Method * cm = class_copyMethodList(c, NULL);
    Method * sm = class_copyMethodList(s, NULL);
    Method * cp, * sp;
    
    for (sp = sm; *sp; sp++)
    {
        SEL nm = method_getName(*sp);
        BOOL fain = YES;
        for (cp = cm; *cp; cp++)
            if (method_getName(*cp) == nm)
            {
                fain = NO;
                break;
            }
        if (!fain) continue;
        class_replaceMethod(c, nm, method_getImplementation(*sp), method_getTypeEncoding(*sp));
    }
    
    free(cm);
    free(sm);
}

+(void)load
{
    [BetterFinder sharedInstance];
}

@end
