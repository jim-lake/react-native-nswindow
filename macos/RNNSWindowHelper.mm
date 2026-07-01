#import "RNNSWindowHelper.h"
#import "RNNSWindow.h"
#import <RCTAppDelegate.h>
#import <React/RCTConvert.h>
#import <React/RCTRootView.h>

@implementation RNNSWindowHelper {
  NSMutableDictionary<NSString *, NSWindow *> *_windows;
  NSMutableDictionary<NSString *, NSString *> *_windowNames;
  NSMutableSet<NSString *> *_preventCloseWindows;
}

+ (instancetype)shared {
  static RNNSWindowHelper *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[RNNSWindowHelper alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _windows = [NSMutableDictionary new];
    _windowNames = [NSMutableDictionary new];
    _preventCloseWindows = [NSMutableSet new];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(notificationWindowWillClose:)
               name:NSWindowWillCloseNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(notificationWindowDidBecomeKey:)
               name:NSWindowDidBecomeKeyNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(notificationWindowDidResignKey:)
               name:NSWindowDidResignKeyNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(notificationWindowDidMove:)
               name:NSWindowDidMoveNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(notificationWindowDidResize:)
               name:NSWindowDidResizeNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(notificationWindowDidMiniaturize:)
               name:NSWindowDidMiniaturizeNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(notificationWindowDidDeminiaturize:)
               name:NSWindowDidDeminiaturizeNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(notificationWindowDidEnterFullScreen:)
               name:NSWindowDidEnterFullScreenNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(notificationWindowDidExitFullScreen:)
               name:NSWindowDidExitFullScreenNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(notificationWindowDidChangeOcclusionState:)
               name:NSWindowDidChangeOcclusionStateNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(notificationWindowDidChangeBackingProperties:)
               name:NSWindowDidChangeBackingPropertiesNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(notificationScreenParametersDidChange:)
               name:NSApplicationDidChangeScreenParametersNotification
             object:nil];
  }
  return self;
}

- (NSString *)windowIdForWindow:(NSWindow *)window {
  for (NSString *key in _windows) {
    if (_windows[key] == window) {
      return key;
    }
  }
  NSString *windowId = [[NSUUID UUID] UUIDString];
  _windows[windowId] = window;
  NSString *name = window.title.length > 0
                       ? window.title
                       : NSStringFromClass([window class]) ?: @"unknown";
  _windowNames[windowId] = name;
  return windowId;
}

- (void)notificationWindowWillClose:(NSNotification *)notification {
  NSWindow *window = notification.object;
  if (!window) {
    return;
  }
  NSString *windowId = [self windowIdForWindow:window];
  [_preventCloseWindows removeObject:windowId];
  [_windows removeObjectForKey:windowId];
  [_windowNames removeObjectForKey:windowId];
  if (self.module) {
    self.module->emitOnWindowClose(std::string([windowId UTF8String]));
  }
}

- (void)notificationWindowDidBecomeKey:(NSNotification *)notification {
  NSWindow *window = notification.object;
  NSString *windowId = [self windowIdForWindow:window];
  if (self.module) {
    self.module->emitOnWindowFocus(std::string([windowId UTF8String]));
  }
}

- (void)notificationWindowDidResignKey:(NSNotification *)notification {
  NSWindow *window = notification.object;
  NSString *windowId = [self windowIdForWindow:window];
  if (!windowId) {
    return;
  }
  if (self.module) {
    self.module->emitOnWindowBlur(std::string([windowId UTF8String]));
  }
}

- (void)notificationWindowDidMove:(NSNotification *)notification {
  NSWindow *window = notification.object;
  NSString *windowId = [self windowIdForWindow:window];
  if (!windowId) {
    return;
  }
  if (self.module) {
    NSRect frame = window.frame;
    facebook::react::WindowMovePayload payload{
        std::string([windowId UTF8String]), frame.origin.x, frame.origin.y};
    self.module->emitOnWindowMove(payload);
  }
}

- (void)notificationWindowDidResize:(NSNotification *)notification {
  NSWindow *window = notification.object;
  NSString *windowId = [self windowIdForWindow:window];
  if (self.module) {
    NSRect frame = window.frame;
    facebook::react::WindowResizePayload payload{
        std::string([windowId UTF8String]), frame.size.width,
        frame.size.height};
    self.module->emitOnWindowResize(payload);
  }
}

- (void)notificationWindowDidMiniaturize:(NSNotification *)notification {
  NSWindow *window = notification.object;
  NSString *windowId = [self windowIdForWindow:window];
  if (self.module) {
    self.module->emitOnWindowMinimize(std::string([windowId UTF8String]));
  }
}

- (void)notificationWindowDidDeminiaturize:(NSNotification *)notification {
  NSWindow *window = notification.object;
  NSString *windowId = [self windowIdForWindow:window];
  if (self.module) {
    self.module->emitOnWindowDeminimize(std::string([windowId UTF8String]));
  }
}

- (void)notificationWindowDidEnterFullScreen:(NSNotification *)notification {
  NSWindow *window = notification.object;
  NSString *windowId = [self windowIdForWindow:window];
  if (self.module) {
    self.module->emitOnWindowEnterFullScreen(
        std::string([windowId UTF8String]));
  }
}

- (void)notificationWindowDidExitFullScreen:(NSNotification *)notification {
  NSWindow *window = notification.object;
  NSString *windowId = [self windowIdForWindow:window];
  if (self.module) {
    self.module->emitOnWindowExitFullScreen(std::string([windowId UTF8String]));
  }
}

- (void)notificationWindowDidChangeOcclusionState:
    (NSNotification *)notification {
  NSWindow *window = notification.object;
  NSString *windowId = [self windowIdForWindow:window];
  if (self.module) {
    bool isVisible =
        (window.occlusionState & NSWindowOcclusionStateVisible) != 0;
    facebook::react::WindowOcclusionStatePayload payload{
        std::string([windowId UTF8String]), isVisible};
    self.module->emitOnWindowOcclusionStateChange(payload);
  }
}

- (void)notificationWindowDidChangeBackingProperties:
    (NSNotification *)notification {
  NSWindow *window = notification.object;
  NSString *windowId = [self windowIdForWindow:window];
  if (self.module) {
    self.module->emitOnWindowBackingPropertiesChange(
        std::string([windowId UTF8String]));
  }
}

- (void)notificationScreenParametersDidChange:(NSNotification *)notification {
  if (self.module) {
    self.module->emitOnScreenInfoChange();
  }
}

- (void)syncWithAppWindows {
  NSArray<NSWindow *> *appWindows = [NSApp windows];

  // Add untracked windows (windowIdForWindow auto-registers)
  for (NSWindow *window in appWindows) {
    [self windowIdForWindow:window];
  }

  // Remove gone windows
  NSMutableArray<NSString *> *toRemove = [NSMutableArray new];
  for (NSString *key in _windows) {
    if (![appWindows containsObject:_windows[key]]) {
      [toRemove addObject:key];
    }
  }
  for (NSString *key in toRemove) {
    [_windows removeObjectForKey:key];
    [_windowNames removeObjectForKey:key];
  }
}

- (NSWindow *_Nullable)windowForId:(NSString *)windowId {
  return _windows[windowId];
}

- (NSArray<NSString *> *)allWindowIds {
  [self syncWithAppWindows];
  return [_windows allKeys];
}

- (NSString *_Nullable)windowNameForId:(NSString *)windowId {
  return _windowNames[windowId];
}

- (void)removeWindowForId:(NSString *)windowId {
  [_windows removeObjectForKey:windowId];
  [_windowNames removeObjectForKey:windowId];
}

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
                          autoSaveFrame:(NSString *_Nullable)autoSaveFrame {

  NSString *windowId = [[NSUUID UUID] UUIDString];

  CGFloat w = width ? width.doubleValue : 400;
  CGFloat h = height ? height.doubleValue : 300;
  CGFloat originX = x ? x.doubleValue : 100;
  CGFloat originY = y ? y.doubleValue : 100;

  NSWindowStyleMask styleMask = NSWindowStyleMaskTitled;
  if (closable) {
    styleMask |= NSWindowStyleMaskClosable;
  }
  if (minimizable) {
    styleMask |= NSWindowStyleMaskMiniaturizable;
  }
  if (resizable) {
    styleMask |= NSWindowStyleMaskResizable;
  }

  NSRect frame = NSMakeRect(originX, originY, w, h);
  NSWindow *window =
      [[NSWindow alloc] initWithContentRect:frame
                                  styleMask:styleMask
                                    backing:NSBackingStoreBuffered
                                      defer:NO];

  window.delegate = self;
  window.releasedWhenClosed = NO;
  window.movable = movable;
  window.hasShadow = hasShadow;

  if (title) {
    window.title = title;
  } else {
    window.title = windowName;
  }

  // Title bar style
  if ([titleBarStyle isEqualToString:@"hidden"]) {
    window.titlebarAppearsTransparent = YES;
    window.titleVisibility = NSWindowTitleHidden;
  } else if ([titleBarStyle isEqualToString:@"hiddenInset"]) {
    window.titlebarAppearsTransparent = YES;
    window.titleVisibility = NSWindowTitleHidden;
    styleMask |= NSWindowStyleMaskFullSizeContentView;
    window.styleMask = styleMask;
  } else if ([titleBarStyle isEqualToString:@"transparent"]) {
    window.titlebarAppearsTransparent = YES;
  }

  // Transparent window
  if (transparent) {
    window.opaque = NO;
  }
  if (backgroundColor) {
    window.backgroundColor = [RCTConvert NSColor:backgroundColor];
  }

  // Min/Max sizes
  if (minWidth || minHeight) {
    window.minSize = NSMakeSize(minWidth ? minWidth.doubleValue : 0,
                                minHeight ? minHeight.doubleValue : 0);
  }
  if (maxWidth || maxHeight) {
    window.maxSize =
        NSMakeSize(maxWidth ? maxWidth.doubleValue : CGFLOAT_MAX,
                   maxHeight ? maxHeight.doubleValue : CGFLOAT_MAX);
  }

  // Window level
  if (alwaysOnTop || [level isEqualToString:@"floating"]) {
    window.level = NSFloatingWindowLevel;
  } else if ([level isEqualToString:@"modalPanel"]) {
    window.level = NSModalPanelWindowLevel;
  } else if ([level isEqualToString:@"mainMenu"]) {
    window.level = NSMainMenuWindowLevel;
  } else if ([level isEqualToString:@"statusBar"]) {
    window.level = NSStatusWindowLevel;
  } else if ([level isEqualToString:@"screenSaver"]) {
    window.level = NSScreenSaverWindowLevel;
  }

  // Vibrancy
  if (vibrancy && ![vibrancy isEqualToString:@"none"]) {
    NSVisualEffectView *effectView =
        [[NSVisualEffectView alloc] initWithFrame:window.contentView.bounds];
    effectView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    effectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    effectView.state = NSVisualEffectStateActive;

    if ([vibrancy isEqualToString:@"sidebar"]) {
      effectView.material = NSVisualEffectMaterialSidebar;
    } else if ([vibrancy isEqualToString:@"menu"]) {
      effectView.material = NSVisualEffectMaterialMenu;
    } else if ([vibrancy isEqualToString:@"popover"]) {
      effectView.material = NSVisualEffectMaterialPopover;
    } else if ([vibrancy isEqualToString:@"fullScreenUI"]) {
      effectView.material = NSVisualEffectMaterialFullScreenUI;
    } else if ([vibrancy isEqualToString:@"underWindowBackground"]) {
      effectView.material = NSVisualEffectMaterialUnderWindowBackground;
    } else if ([vibrancy isEqualToString:@"hudWindow"]) {
      effectView.material = NSVisualEffectMaterialHUDWindow;
    }

    window.contentView = effectView;
  }

  // Auto-save frame
  if (autoSaveFrame) {
    [window setFrameAutosaveName:autoSaveFrame];
  }

  // Center
  if (center) {
    [window center];
  }

  // Create React root view via RCTRootViewFactory
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  RCTAppDelegate *appDelegate = (RCTAppDelegate *)[NSApp delegate];
#pragma clang diagnostic pop
  RCTRootViewFactory *factory = [appDelegate rootViewFactory];
  NSView *rootView = [factory viewWithModuleName:componentName
                               initialProperties:initialProps];

  if (vibrancy && ![vibrancy isEqualToString:@"none"]) {
    rootView.frame = window.contentView.bounds;
    rootView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [window.contentView addSubview:rootView];
  } else {
    window.contentView = rootView;
  }

  _windows[windowId] = window;
  _windowNames[windowId] = windowName;

  // Zoomable
  if (!zoomable) {
    NSButton *zoomBtn = [window standardWindowButton:NSWindowZoomButton];
    if (zoomBtn) {
      zoomBtn.enabled = NO;
    }
  }

  // Show/focus
  if (show) {
    if (focusOnCreate) {
      [window makeKeyAndOrderFront:nil];
    } else {
      [window orderFront:nil];
    }
  }

  return windowId;
}

- (NSVisualEffectMaterial)materialForVibrancy:(NSString *)vibrancy {
  if ([vibrancy isEqualToString:@"sidebar"]) {
    return NSVisualEffectMaterialSidebar;
  } else if ([vibrancy isEqualToString:@"menu"]) {
    return NSVisualEffectMaterialMenu;
  } else if ([vibrancy isEqualToString:@"popover"]) {
    return NSVisualEffectMaterialPopover;
  } else if ([vibrancy isEqualToString:@"fullScreenUI"]) {
    return NSVisualEffectMaterialFullScreenUI;
  } else if ([vibrancy isEqualToString:@"underWindowBackground"]) {
    return NSVisualEffectMaterialUnderWindowBackground;
  } else if ([vibrancy isEqualToString:@"hudWindow"]) {
    return NSVisualEffectMaterialHUDWindow;
  }
  return NSVisualEffectMaterialWindowBackground;
}

#pragma mark - NSWindowDelegate

- (BOOL)windowShouldClose:(NSWindow *)sender {
  NSString *windowId = [self windowIdForWindow:sender];
  if (self.module) {
    self.module->emitOnWindowWillClose(std::string([windowId UTF8String]));
  }
  if ([_preventCloseWindows containsObject:windowId]) {
    return NO;
  }
  return YES;
}

- (void)setStopShouldClose:(BOOL)stop forWindowId:(NSString *)windowId {
  if (stop) {
    [_preventCloseWindows addObject:windowId];
  } else {
    [_preventCloseWindows removeObject:windowId];
  }
}

@end
