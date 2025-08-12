//
//  WindowInfo.h
//  SizeUpSwapperInObjc
//
//  Created by Wei Sun on 2025/8/12.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface WindowInfo : NSObject

@property (nonatomic, readonly) CGWindowID windowID;
@property (nonatomic, readonly) pid_t ownerPID;
@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, readonly, nullable) NSString *appName;
@property (nonatomic, readonly, nullable) NSString *windowTitle;
@property (nonatomic, readonly) NSInteger layer;

- (instancetype)initWithWindowID:(CGWindowID)windowID
                         ownerPID:(pid_t)ownerPID
                            frame:(CGRect)frame
                          appName:(nullable NSString *)appName
                      windowTitle:(nullable NSString *)windowTitle
                            layer:(NSInteger)layer NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (NSString *)description;

@end

NS_ASSUME_NONNULL_END