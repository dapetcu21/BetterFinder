//
//  BetterFinder.h
//  BetterFinder
//
//  Created by Marius Petcu on 9/3/12.
//  Copyright (c) 2012 Marius Petcu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class TPreferencesWindowController;

@interface BetterFinder : NSObject
{
    NSConnection * conn;
    
    Class TPreferencesWindowController$;
}
@end

#define BFDefineMethod(ret, cls, name, ...) ret (*name ## _orig)(cls * self, SEL _cmd, ##__VA_ARGS__) = NULL; ret name(cls * self, SEL _cmd, ##__VA_ARGS__)
#define BFDeclareMethod(ret, cls, name, ...) extern ret (*name ## _orig)(cls * self, SEL _cmd, ##__VA_ARGS__); ret name(cls * self, SEL _cmd, ##__VA_ARGS__);
#define BFReplaceMethod(cls, sel, types, name) (*((IMP*)&(name ## _orig))) = class_replaceMethod(cls, sel, (IMP)name, types)
#define BFGetClass(cls) cls ## $ = objc_getClass(#cls)
#define BFGetMetaClass(cls) cls ## $$ = objc_getMetaClass(#cls)