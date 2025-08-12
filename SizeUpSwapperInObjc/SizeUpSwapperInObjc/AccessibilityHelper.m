//
//  AccessibilityHelper.m
//  SizeUpSwapperInObjc
//
//  Created by Wei Sun on 2025/8/12.
//

#import "AccessibilityHelper.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation AccessibilityHelper

+ (BOOL)checkPermissions {
    return AXIsProcessTrusted();
}

+ (void)promptForPermissions {
    printf("\n");
    printf("⚠️  Accessibility permissions are required for this application to work.\n\n");
    printf("To grant permissions:\n");
    printf("1. Open System Settings\n");
    printf("2. Go to Privacy & Security → Accessibility\n");
    printf("3. Click the lock icon to make changes\n");
    printf("4. Add this application to the list (or enable if already present)\n");
    printf("5. Re-run this application\n\n");
    printf("Alternatively, run this command to open the Accessibility settings:\n");
    printf("open \"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility\"\n\n");
    
    NSDictionary *options = @{ (__bridge NSString *)kAXTrustedCheckOptionPrompt : @YES };
    AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
}

+ (BOOL)ensurePermissions {
    if ([self checkPermissions]) {
        printf("✓ Accessibility permissions granted\n\n");
        return YES;
    } else {
        printf("✗ Accessibility permissions not granted\n");
        [self promptForPermissions];
        return NO;
    }
}

@end