//
//  BetterFinder.h
//  BetterFinder
//
//  Created by Marius Petcu on 9/3/12.
//  Copyright (c) 2012 Marius Petcu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class BFPrefPane;
@class TPreferencesWindowController;

@interface BetterFinder : NSObject
{
    NSConnection * conn;
    
    Class TPreferencesWindowController$;
    
    NSMutableDictionary * toolbarItems;
    NSMutableArray * toolbarOrder;
    
    NSBundle * bundle;
    
    BFPrefPane * pane;
}
-(NSBundle*)bundle;

+(BetterFinder*) sharedInstance;
@end

#define BFDefineMethod(ret, cls, name, ...) ret (*name ## _orig)(cls * self, SEL _cmd, ##__VA_ARGS__) = NULL; ret name(cls * self, SEL _cmd, ##__VA_ARGS__)
#define BFDeclareMethod(ret, cls, name, ...) extern ret (*name ## _orig)(cls * self, SEL _cmd, ##__VA_ARGS__); ret name(cls * self, SEL _cmd, ##__VA_ARGS__);
#define BFReplaceMethod(cls, sel, types, name) (*((IMP*)&(name ## _orig))) = class_replaceMethod(cls, @selector(sel), (IMP)name, types)
#define BFRestoreMethod(cls, sel, types, name) class_replaceMethod(cls, @selector(sel), (IMP)(name ## _orig), types)
#define BFGetClass(cls) cls ## $ = objc_getClass(#cls)
#define BFGetMetaClass(cls) cls ## $$ = objc_getMetaClass(#cls)

inline ptrdiff_t BFIvarOffset(Class c, const char * s);
#define BFIvarFromOffset(type, slf, off) (*((type *)(void*)((char*)(void*)(slf) + off)))
inline void * _BFIvar(id self, const char * s);
#define BFIvar(type, slf, s) (*((type*)_BFIvar(slf, s)))

void BFSoftSubclass(const char * clss, const char * superclss);