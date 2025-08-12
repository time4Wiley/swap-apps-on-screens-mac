//
//  WindowInfo.m
//  SizeUpSwapperInObjc
//
//  Created by Wei Sun on 2025/8/12.
//

#import "WindowInfo.h"

@implementation WindowInfo

- (instancetype)initWithWindowID:(CGWindowID)windowID
                         ownerPID:(pid_t)ownerPID
                            frame:(CGRect)frame
                          appName:(nullable NSString *)appName
                      windowTitle:(nullable NSString *)windowTitle
                            layer:(NSInteger)layer {
    self = [super init];
    if (self) {
        _windowID = windowID;
        _ownerPID = ownerPID;
        _frame = frame;
        _appName = [appName copy];
        _windowTitle = [windowTitle copy];
        _layer = layer;
    }
    return self;
}

- (NSString *)description {
    NSMutableString *desc = [NSMutableString stringWithFormat:@"Window ID: %d", self.windowID];
    
    if (self.appName) {
        [desc appendFormat:@", App: %@", self.appName];
    }
    
    if (self.windowTitle && self.windowTitle.length > 0) {
        [desc appendFormat:@", Title: \"%@\"", self.windowTitle];
    }
    
    [desc appendFormat:@", Position: (%d, %d)", 
           (int)self.frame.origin.x, (int)self.frame.origin.y];
    [desc appendFormat:@", Size: %dx%d", 
           (int)self.frame.size.width, (int)self.frame.size.height];
    [desc appendFormat:@", PID: %d", self.ownerPID];
    
    return desc;
}

@end