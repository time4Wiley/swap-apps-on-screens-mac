//
//  main.m
//  SizeUpSwapperInObjc
//
//  Created by Wei Sun on 2025/8/12.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "WindowInfo.h"
#import "WindowDetector.h"
#import "AccessibilityHelper.h"

void printLine(const char *format, ...) {
    va_list args;
    va_start(args, format);
    vprintf(format, args);
    va_end(args);
    printf("\n");
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        printLine("SizeUp Window Swapper (Objective-C)");
        printLine("====================================");
        printLine("");
        
        // Check accessibility permissions
        printLine("Checking accessibility permissions...");
        if (![AccessibilityHelper ensurePermissions]) {
            printLine("❌ Cannot proceed without accessibility permissions.");
            return 1;
        }
        
        // Check if SizeUp is running
        NSArray<NSRunningApplication *> *runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
        BOOL sizeUpRunning = NO;
        for (NSRunningApplication *app in runningApps) {
            if ([app.bundleIdentifier isEqualToString:@"com.irradiatedsoftware.SizeUp"]) {
                sizeUpRunning = YES;
                break;
            }
        }
        
        if (!sizeUpRunning) {
            printLine("⚠️  SizeUp doesn't appear to be running.");
            printLine("Please ensure SizeUp is installed and running.");
            printLine("You can download it from: https://www.irradiatedsoftware.com/sizeup/");
            return 1;
        }
        
        printLine("✓ SizeUp is running");
        printLine("");
        
        // Detect screens and windows
        printLine("Detecting screens and windows...");
        NSArray<ScreenInfo *> *screenInfo = [WindowDetector getScreenInfo];
        
        if (screenInfo.count < 2) {
            printLine("❌ This tool requires at least 2 screens.");
            printLine("Currently detected: %lu screen(s)", (unsigned long)screenInfo.count);
            return 1;
        }
        
        NSArray<ScreenWindowPair *> *screenWindowPairs = [WindowDetector topWindowsPerScreen];
        
        // Count how many screens have windows
        NSUInteger windowCount = 0;
        for (ScreenWindowPair *pair in screenWindowPairs) {
            if (pair.window != nil) {
                windowCount++;
            }
        }
        
        if (windowCount < 2) {
            printLine("❌ Need at least one window on each of two screens.");
            printLine("Currently detected: %lu window(s) across screens", (unsigned long)windowCount);
            return 1;
        }
        
        // Display current state
        printLine("");
        printLine("Current window configuration:");
        printLine("-----------------------------");
        NSMutableArray<WindowInfo *> *windowsToSwap = [NSMutableArray array];
        
        for (NSUInteger index = 0; index < screenInfo.count && index < screenWindowPairs.count; index++) {
            ScreenInfo *info = screenInfo[index];
            ScreenWindowPair *pair = screenWindowPairs[index];
            NSString *screenName = info.name;
            NSUInteger screenNumber = index + 1;
            
            printLine("");
            printLine("Screen %lu: %s", (unsigned long)screenNumber, [screenName UTF8String]);
            
            WindowInfo *window = pair.window;
            if (window) {
                printLine("  Window: %s - %s", 
                    [window.appName ?: @"Unknown" UTF8String],
                    [window.windowTitle ?: @"No title" UTF8String]);
                printLine("  Position: (%d, %d)", 
                    (int)window.frame.origin.x, 
                    (int)window.frame.origin.y);
                [windowsToSwap addObject:window];
            } else {
                printLine("  No window detected");
            }
        }
        
        if (windowsToSwap.count < 2) {
            printLine("");
            printLine("❌ Not enough windows to swap");
            return 1;
        }
        
        // Save the currently active application
        NSRunningApplication *activeApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
        printLine("");
        printLine("💾 Current active app: %s", 
            [activeApp.localizedName ?: @"Unknown" UTF8String]);
        
        // Perform the swap using SizeUp
        printLine("");
        printLine("🔄 Swapping windows using SizeUp...");
        
        // We need to activate each window and tell SizeUp to move it to the next monitor
        for (NSUInteger index = 0; index < windowsToSwap.count; index++) {
            WindowInfo *window = windowsToSwap[index];
            printLine("");
            printLine("Moving window %lu: %s", 
                (unsigned long)(index + 1), 
                [window.appName ?: @"Unknown" UTF8String]);
            
            // First, we need to activate the window's application
            NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier:window.ownerPID];
            if (app) {
                [app activateWithOptions:NSApplicationActivateIgnoringOtherApps];
                
                // Give the app time to activate
                [NSThread sleepForTimeInterval:0.2];
                
                // Now use AppleScript to tell SizeUp to move the window
                NSString *scriptSource = @"tell application \"SizeUp\"\n"
                                         @"    do action Next Monitor\n"
                                         @"end tell";
                
                NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:scriptSource];
                if (appleScript) {
                    NSDictionary *error = nil;
                    [appleScript executeAndReturnError:&error];
                    
                    if (error) {
                        printLine("  ❌ Failed to move window: %s", 
                            [[error description] UTF8String]);
                    } else {
                        printLine("  ✅ Window moved to next monitor");
                    }
                    
                    // Give SizeUp time to complete the move
                    [NSThread sleepForTimeInterval:0.3];
                } else {
                    printLine("  ❌ Failed to create AppleScript");
                }
            } else {
                printLine("  ❌ Could not activate application with PID %d", window.ownerPID);
            }
        }
        
        // Restore the originally active application
        if (activeApp) {
            printLine("");
            printLine("🔄 Restoring active app: %s", 
                [activeApp.localizedName ?: @"Unknown" UTF8String]);
            [activeApp activateWithOptions:NSApplicationActivateIgnoringOtherApps];
            [NSThread sleepForTimeInterval:0.1];
        }
        
        printLine("");
        printLine("✨ Done! Windows should now be swapped.");
        printLine("");
        printLine("Note: SizeUp moves each window to the 'next' monitor in its list.");
        printLine("If you have more than 2 monitors, the behavior may differ from a simple swap.");
    }
    return 0;
}
