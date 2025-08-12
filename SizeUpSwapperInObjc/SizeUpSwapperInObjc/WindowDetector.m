//
//  WindowDetector.m
//  SizeUpSwapperInObjc
//
//  Created by Wei Sun on 2025/8/12.
//

#import "WindowDetector.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation ScreenInfo
@end

@implementation ScreenWindowPair
@end

@implementation WindowDetector

+ (NSArray<ScreenWindowPair *> *)topWindowsPerScreen {
    CFArrayRef windowList = CGWindowListCopyWindowInfo(
        kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements,
        kCGNullWindowID
    );
    
    NSArray<NSScreen *> *screens = [NSScreen screens];
    NSMutableArray<ScreenWindowPair *> *result = [NSMutableArray array];
    
    // Initialize result with all screens
    for (NSScreen *screen in screens) {
        ScreenWindowPair *pair = [[ScreenWindowPair alloc] init];
        pair.screen = screen;
        pair.window = nil;
        [result addObject:pair];
    }
    
    if (!windowList) {
        return [result copy];
    }
    
    NSArray *windows = (__bridge NSArray *)windowList;
    
    for (NSDictionary *windowDict in windows) {
        NSNumber *layerNum = windowDict[(__bridge NSString *)kCGWindowLayer];
        if (!layerNum || [layerNum integerValue] != 0) {
            continue;
        }
        
        NSNumber *pidNum = windowDict[(__bridge NSString *)kCGWindowOwnerPID];
        NSNumber *windowIDNum = windowDict[(__bridge NSString *)kCGWindowNumber];
        NSDictionary *boundsDict = windowDict[(__bridge NSString *)kCGWindowBounds];
        
        if (!pidNum || !windowIDNum || !boundsDict) {
            continue;
        }
        
        CGRect windowBounds;
        CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)boundsDict, &windowBounds);
        
        NSString *appName = windowDict[(__bridge NSString *)kCGWindowOwnerName];
        NSString *windowTitle = windowDict[(__bridge NSString *)kCGWindowName];
        
        WindowInfo *windowInfo = [[WindowInfo alloc] 
            initWithWindowID:[windowIDNum unsignedIntValue]
            ownerPID:[pidNum intValue]
            frame:windowBounds
            appName:appName
            windowTitle:windowTitle
            layer:[layerNum integerValue]];
        
        // Find which screen this window belongs to
        for (ScreenWindowPair *pair in result) {
            if (pair.window == nil && 
                NSIntersectsRect(pair.screen.frame, NSRectFromCGRect(windowBounds))) {
                pair.window = windowInfo;
                break;
            }
        }
        
        // Check if all screens have windows
        BOOL allScreensHaveWindows = YES;
        for (ScreenWindowPair *pair in result) {
            if (pair.window == nil) {
                allScreensHaveWindows = NO;
                break;
            }
        }
        
        if (allScreensHaveWindows) {
            break;
        }
    }
    
    CFRelease(windowList);
    return [result copy];
}

+ (NSArray<WindowInfo *> *)getAllWindowsInfo {
    CFArrayRef windowList = CGWindowListCopyWindowInfo(
        kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements,
        kCGNullWindowID
    );
    
    if (!windowList) {
        return @[];
    }
    
    NSArray *windows = (__bridge NSArray *)windowList;
    NSMutableArray<WindowInfo *> *result = [NSMutableArray array];
    
    for (NSDictionary *windowDict in windows) {
        NSNumber *layerNum = windowDict[(__bridge NSString *)kCGWindowLayer];
        if (!layerNum || [layerNum integerValue] != 0) {
            continue;
        }
        
        NSNumber *pidNum = windowDict[(__bridge NSString *)kCGWindowOwnerPID];
        NSNumber *windowIDNum = windowDict[(__bridge NSString *)kCGWindowNumber];
        NSDictionary *boundsDict = windowDict[(__bridge NSString *)kCGWindowBounds];
        
        if (!pidNum || !windowIDNum || !boundsDict) {
            continue;
        }
        
        CGRect windowBounds;
        CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)boundsDict, &windowBounds);
        
        NSString *appName = windowDict[(__bridge NSString *)kCGWindowOwnerName];
        NSString *windowTitle = windowDict[(__bridge NSString *)kCGWindowName];
        
        WindowInfo *windowInfo = [[WindowInfo alloc] 
            initWithWindowID:[windowIDNum unsignedIntValue]
            ownerPID:[pidNum intValue]
            frame:windowBounds
            appName:appName
            windowTitle:windowTitle
            layer:[layerNum integerValue]];
        
        [result addObject:windowInfo];
    }
    
    CFRelease(windowList);
    return [result copy];
}

+ (NSArray<ScreenInfo *> *)getScreenInfo {
    NSArray<NSScreen *> *screens = [NSScreen screens];
    NSMutableArray<ScreenInfo *> *result = [NSMutableArray array];
    
    for (NSScreen *screen in screens) {
        ScreenInfo *info = [[ScreenInfo alloc] init];
        info.screen = screen;
        info.name = screen.localizedName;
        [result addObject:info];
    }
    
    return [result copy];
}

@end