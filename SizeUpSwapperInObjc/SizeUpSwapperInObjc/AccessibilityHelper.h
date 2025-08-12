//
//  AccessibilityHelper.h
//  SizeUpSwapperInObjc
//
//  Created by Wei Sun on 2025/8/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AccessibilityHelper : NSObject

+ (BOOL)checkPermissions;
+ (void)promptForPermissions;
+ (BOOL)ensurePermissions;

@end

NS_ASSUME_NONNULL_END