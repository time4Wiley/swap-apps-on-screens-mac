//
//  WindowDetector.h
//  SizeUpSwapperInObjc
//
//  Created by Wei Sun on 2025/8/12.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "WindowInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScreenInfo : NSObject
@property (nonatomic, strong) NSScreen *screen;
@property (nonatomic, strong) NSString *name;
@end

@interface ScreenWindowPair : NSObject
@property (nonatomic, strong) NSScreen *screen;
@property (nonatomic, strong, nullable) WindowInfo *window;
@end

@interface WindowDetector : NSObject

+ (NSArray<ScreenWindowPair *> *)topWindowsPerScreen;
+ (NSArray<WindowInfo *> *)getAllWindowsInfo;
+ (NSArray<ScreenInfo *> *)getScreenInfo;

@end

NS_ASSUME_NONNULL_END