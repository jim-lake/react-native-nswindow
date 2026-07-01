#pragma once

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

namespace facebook::react {
class RNNSWindow;
}

@interface RNNSWindowHelper : NSObject <NSWindowDelegate>

@property(nonatomic, assign) facebook::react::RNNSWindow *module;

+ (instancetype)shared;

- (NSString *)createWindowWithComponent:(NSString *)componentName
                             windowName:(NSString *)windowName
                           initialProps:(NSDictionary *_Nullable)initialProps
                                      x:(NSNumber *_Nullable)x
                                      y:(NSNumber *_Nullable)y
                                  width:(NSNumber *_Nullable)width
                                 height:(NSNumber *_Nullable)height
                               minWidth:(NSNumber *_Nullable)minWidth
                              minHeight:(NSNumber *_Nullable)minHeight
                               maxWidth:(NSNumber *_Nullable)maxWidth
                              maxHeight:(NSNumber *_Nullable)maxHeight
                                 center:(BOOL)center
                                  title:(NSString *_Nullable)title
                          titleBarStyle:(NSString *_Nullable)titleBarStyle
                               vibrancy:(NSString *_Nullable)vibrancy
                        backgroundColor:(NSString *_Nullable)backgroundColor
                            transparent:(BOOL)transparent
                              hasShadow:(BOOL)hasShadow
                              resizable:(BOOL)resizable
                                movable:(BOOL)movable
                            minimizable:(BOOL)minimizable
                               closable:(BOOL)closable
                               zoomable:(BOOL)zoomable
                            alwaysOnTop:(BOOL)alwaysOnTop
                                  level:(NSString *_Nullable)level
                                   show:(BOOL)show
                          focusOnCreate:(BOOL)focusOnCreate
                          autoSaveFrame:(NSString *_Nullable)autoSaveFrame;

- (NSWindow *_Nullable)windowForId:(NSString *)windowId;
- (NSArray<NSString *> *)allWindowIds;
- (NSString *_Nullable)windowNameForId:(NSString *)windowId;
- (void)removeWindowForId:(NSString *)windowId;
- (void)setStopShouldClose:(BOOL)stop forWindowId:(NSString *)windowId;
- (NSVisualEffectMaterial)materialForVibrancy:(NSString *)vibrancy;

@end
