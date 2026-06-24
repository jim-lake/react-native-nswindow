#import "RNNSWindow.h"
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import <RCTAppDelegate.h>
#import <React/RCTRootView.h>

// Obj-C helper — all access on main thread only (lockless)
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
@end

@implementation RNNSWindowHelper {
  NSMutableDictionary<NSString *, NSWindow *> *_windows;
  NSMutableDictionary<NSString *, NSString *> *_windowNames;
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
  _windowNames[windowId] = @"external";
  return windowId;
}

- (void)notificationWindowWillClose:(NSNotification *)notification {
  NSWindow *window = notification.object;
  if (!window) {
    return;
  }
  NSString *windowId = [self windowIdForWindow:window];
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
  if (self.module) {
    self.module->emitOnWindowBlur(std::string([windowId UTF8String]));
  }
}

- (void)notificationWindowDidMove:(NSNotification *)notification {
  NSWindow *window = notification.object;
  NSString *windowId = [self windowIdForWindow:window];
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

- (void)syncWithAppWindows {
  NSArray<NSWindow *> *appWindows = [NSApp windows];

  // Add untracked windows
  for (NSWindow *window in appWindows) {
    BOOL found = NO;
    for (NSWindow *tracked in _windows.allValues) {
      if (tracked == window) {
        found = YES;
        break;
      }
    }
    if (!found) {
      NSString *windowId = [[NSUUID UUID] UUIDString];
      _windows[windowId] = window;
      _windowNames[windowId] = @"external";
    }
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
    window.backgroundColor = [NSColor clearColor];
  } else if (backgroundColor) {
    window.backgroundColor = [self colorFromHex:backgroundColor];
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

- (NSColor *)colorFromHex:(NSString *)hex {
  NSString *clean = [hex stringByReplacingOccurrencesOfString:@"#"
                                                   withString:@""];
  unsigned int rgb = 0;
  [[NSScanner scannerWithString:clean] scanHexInt:&rgb];
  CGFloat r = ((rgb >> 16) & 0xFF) / 255.0;
  CGFloat g = ((rgb >> 8) & 0xFF) / 255.0;
  CGFloat b = (rgb & 0xFF) / 255.0;
  return [NSColor colorWithRed:r green:g blue:b alpha:1.0];
}

#pragma mark - NSWindowDelegate

@end

// ─── C++ Implementation ───

namespace facebook::react {

RNNSWindow::RNNSWindow(std::shared_ptr<CallInvoker> jsInvoker)
    : NativeNSWindowCxxSpec(std::move(jsInvoker)) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [RNNSWindowHelper shared].module = this;
  });
}

jsi::Value RNNSWindow::addWindow(jsi::Runtime &rt, jsi::Object props) {
  auto p = NativeNSWindowWindowPropsBridging<WindowProps>::fromJs(rt, props,
                                                                  jsInvoker_);

  NSString *nsComponentName =
      [NSString stringWithUTF8String:p.componentName.c_str()];
  NSString *nsWindowName = [NSString stringWithUTF8String:p.windowName.c_str()];

  auto toNSString = [](const std::optional<std::string> &s) -> NSString * {
    return s ? [NSString stringWithUTF8String:s->c_str()] : nil;
  };
  auto toNSNumber = [](const std::optional<double> &d) -> NSNumber * {
    return d ? @(*d) : nil;
  };

  // Convert initialProps jsi::Object → NSDictionary (shallow)
  NSDictionary *initialProps = nil;
  {
    auto names = p.initialProps.getPropertyNames(rt);
    if (names.size(rt) > 0) {
      NSMutableDictionary *dict = [NSMutableDictionary new];
      for (size_t i = 0; i < names.size(rt); i++) {
        auto name = names.getValueAtIndex(rt, i).asString(rt);
        auto val = p.initialProps.getProperty(rt, name);
        NSString *key = [NSString stringWithUTF8String:name.utf8(rt).c_str()];
        if (val.isString()) {
          dict[key] =
              [NSString stringWithUTF8String:val.asString(rt).utf8(rt).c_str()];
        } else if (val.isNumber()) {
          dict[key] = @(val.asNumber());
        } else if (val.isBool()) {
          dict[key] = @(val.getBool());
        }
      }
      initialProps = dict;
    }
  }

  NSNumber *x = toNSNumber(p.x);
  NSNumber *y = toNSNumber(p.y);
  NSNumber *width = toNSNumber(p.width);
  NSNumber *height = toNSNumber(p.height);
  NSNumber *minWidth = toNSNumber(p.minWidth);
  NSNumber *minHeight = toNSNumber(p.minHeight);
  NSNumber *maxWidth = toNSNumber(p.maxWidth);
  NSNumber *maxHeight = toNSNumber(p.maxHeight);
  BOOL center = p.center.value_or(false);
  NSString *title = toNSString(p.title);
  NSString *titleBarStyle = toNSString(p.titleBarStyle);
  NSString *vibrancy = toNSString(p.vibrancy);
  NSString *backgroundColor = toNSString(p.backgroundColor);
  BOOL transparent = p.transparent.value_or(false);
  BOOL hasShadow = p.hasShadow.value_or(true);
  BOOL resizable = p.resizable.value_or(true);
  BOOL movable = p.movable.value_or(true);
  BOOL minimizable = p.minimizable.value_or(true);
  BOOL closable = p.closable.value_or(true);
  BOOL zoomable = p.zoomable.value_or(true);
  BOOL alwaysOnTop = p.alwaysOnTop.value_or(false);
  NSString *level = toNSString(p.level);
  BOOL show = p.show.value_or(true);
  BOOL focusOnCreate = p.focusOnCreate.value_or(true);
  NSString *autoSaveFrame = toNSString(p.autoSaveFrame);

  return createPromiseAsJSIValue(
      rt, [=, this](jsi::Runtime &, std::shared_ptr<Promise> promise) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSString *windowId = [[RNNSWindowHelper shared]
              createWindowWithComponent:nsComponentName
                             windowName:nsWindowName
                           initialProps:initialProps
                                      x:x
                                      y:y
                                  width:width
                                 height:height
                               minWidth:minWidth
                              minHeight:minHeight
                               maxWidth:maxWidth
                              maxHeight:maxHeight
                                 center:center
                                  title:title
                          titleBarStyle:titleBarStyle
                               vibrancy:vibrancy
                        backgroundColor:backgroundColor
                            transparent:transparent
                              hasShadow:hasShadow
                              resizable:resizable
                                movable:movable
                            minimizable:minimizable
                               closable:closable
                               zoomable:zoomable
                            alwaysOnTop:alwaysOnTop
                                  level:level
                                   show:show
                          focusOnCreate:focusOnCreate
                          autoSaveFrame:autoSaveFrame];

          std::string wid = [windowId UTF8String];
          jsInvoker_->invokeAsync([promise, wid](jsi::Runtime &rt3) {
            promise->resolve(jsi::String::createFromUtf8(rt3, wid));
          });
        });
      });
}

jsi::Value RNNSWindow::closeWindow(jsi::Runtime &rt, jsi::String windowId) {
  std::string wid = windowId.utf8(rt);
  return createPromiseAsJSIValue(
      rt, [=, this](jsi::Runtime &, std::shared_ptr<Promise> promise) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSString *nsWid = [NSString stringWithUTF8String:wid.c_str()];
          NSWindow *window = [[RNNSWindowHelper shared] windowForId:nsWid];
          [window close];

          jsInvoker_->invokeAsync([promise](jsi::Runtime &) {
            promise->resolve(jsi::Value::undefined());
          });
        });
      });
}

jsi::Value RNNSWindow::modifyWindow(jsi::Runtime &rt, jsi::String windowId,
                                    jsi::Object props) {
  std::string wid = windowId.utf8(rt);
  return createPromiseAsJSIValue(
      rt, [=, this](jsi::Runtime &, std::shared_ptr<Promise> promise) {
        jsInvoker_->invokeAsync([promise](jsi::Runtime &) {
          promise->resolve(jsi::Value::undefined());
        });
      });
}

jsi::Value RNNSWindow::listWindows(jsi::Runtime &rt) {
  return createPromiseAsJSIValue(rt, [this](jsi::Runtime &,
                                            std::shared_ptr<Promise> promise) {
    dispatch_async(dispatch_get_main_queue(), ^{
      NSArray<NSString *> *ids = [[RNNSWindowHelper shared] allWindowIds];
      std::vector<std::string> vec;
      for (NSString *wid in ids) {
        vec.push_back([wid UTF8String]);
      }
      jsInvoker_->invokeAsync([promise,
                               vec = std::move(vec)](jsi::Runtime &rt2) {
        auto arr = jsi::Array(rt2, vec.size());
        for (size_t i = 0; i < vec.size(); i++) {
          arr.setValueAtIndex(rt2, i, jsi::String::createFromUtf8(rt2, vec[i]));
        }
        promise->resolve(std::move(arr));
      });
    });
  });
}

jsi::Value RNNSWindow::getWindowState(jsi::Runtime &rt, jsi::String windowId) {
  std::string wid = windowId.utf8(rt);
  return createPromiseAsJSIValue(rt, [=,
                                      this](jsi::Runtime &,
                                            std::shared_ptr<Promise> promise) {
    dispatch_async(dispatch_get_main_queue(), ^{
      NSString *nsWid = [NSString stringWithUTF8String:wid.c_str()];
      NSWindow *window = [[RNNSWindowHelper shared] windowForId:nsWid];
      NSString *name = [[RNNSWindowHelper shared] windowNameForId:nsWid] ?: @"";

      if (!window) {
        jsInvoker_->invokeAsync([promise, wid](jsi::Runtime &) {
          promise->reject("Window not found: " + wid);
        });
        return;
      }

      NSRect frame = window.frame;
      bool isKey = [window isKeyWindow];
      bool isMini = [window isMiniaturized];
      bool isFS = (window.styleMask & NSWindowStyleMaskFullScreen) != 0;
      bool isVis = [window isVisible];
      std::string nameStr = [name UTF8String];
      double x = frame.origin.x;
      double y = frame.origin.y;
      double w = frame.size.width;
      double h = frame.size.height;

      jsInvoker_->invokeAsync([promise, wid, nameStr, x, y, w, h, isKey, isMini,
                               isFS, isVis](jsi::Runtime &rt2) {
        auto obj = jsi::Object(rt2);
        obj.setProperty(rt2, "windowId", jsi::String::createFromUtf8(rt2, wid));
        obj.setProperty(rt2, "windowName",
                        jsi::String::createFromUtf8(rt2, nameStr));
        obj.setProperty(rt2, "x", x);
        obj.setProperty(rt2, "y", y);
        obj.setProperty(rt2, "width", w);
        obj.setProperty(rt2, "height", h);
        obj.setProperty(rt2, "isKeyWindow", isKey);
        obj.setProperty(rt2, "isMinimized", isMini);
        obj.setProperty(rt2, "isFullScreen", isFS);
        obj.setProperty(rt2, "isVisible", isVis);
        promise->resolve(std::move(obj));
      });
    });
  });
}

jsi::Value RNNSWindow::focusWindow(jsi::Runtime &rt, jsi::String windowId) {
  std::string wid = windowId.utf8(rt);
  return createPromiseAsJSIValue(
      rt, [=, this](jsi::Runtime &, std::shared_ptr<Promise> promise) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSString *nsWid = [NSString stringWithUTF8String:wid.c_str()];
          NSWindow *window = [[RNNSWindowHelper shared] windowForId:nsWid];
          [window makeKeyAndOrderFront:nil];

          jsInvoker_->invokeAsync([promise](jsi::Runtime &) {
            promise->resolve(jsi::Value::undefined());
          });
        });
      });
}

jsi::Value RNNSWindow::hideWindow(jsi::Runtime &rt, jsi::String windowId) {
  std::string wid = windowId.utf8(rt);
  return createPromiseAsJSIValue(
      rt, [=, this](jsi::Runtime &, std::shared_ptr<Promise> promise) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSString *nsWid = [NSString stringWithUTF8String:wid.c_str()];
          NSWindow *window = [[RNNSWindowHelper shared] windowForId:nsWid];
          [window orderOut:nil];

          jsInvoker_->invokeAsync([promise](jsi::Runtime &) {
            promise->resolve(jsi::Value::undefined());
          });
        });
      });
}

jsi::Value RNNSWindow::showWindow(jsi::Runtime &rt, jsi::String windowId) {
  std::string wid = windowId.utf8(rt);
  return createPromiseAsJSIValue(
      rt, [=, this](jsi::Runtime &, std::shared_ptr<Promise> promise) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSString *nsWid = [NSString stringWithUTF8String:wid.c_str()];
          NSWindow *window = [[RNNSWindowHelper shared] windowForId:nsWid];
          [window orderFront:nil];

          jsInvoker_->invokeAsync([promise](jsi::Runtime &) {
            promise->resolve(jsi::Value::undefined());
          });
        });
      });
}

jsi::Value RNNSWindow::minimizeWindow(jsi::Runtime &rt, jsi::String windowId) {
  std::string wid = windowId.utf8(rt);
  return createPromiseAsJSIValue(
      rt, [=, this](jsi::Runtime &, std::shared_ptr<Promise> promise) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSString *nsWid = [NSString stringWithUTF8String:wid.c_str()];
          NSWindow *window = [[RNNSWindowHelper shared] windowForId:nsWid];
          [window miniaturize:nil];

          jsInvoker_->invokeAsync([promise](jsi::Runtime &) {
            promise->resolve(jsi::Value::undefined());
          });
        });
      });
}

jsi::Value RNNSWindow::deminimizeWindow(jsi::Runtime &rt,
                                        jsi::String windowId) {
  std::string wid = windowId.utf8(rt);
  return createPromiseAsJSIValue(
      rt, [=, this](jsi::Runtime &, std::shared_ptr<Promise> promise) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSString *nsWid = [NSString stringWithUTF8String:wid.c_str()];
          NSWindow *window = [[RNNSWindowHelper shared] windowForId:nsWid];
          [window deminiaturize:nil];

          jsInvoker_->invokeAsync([promise](jsi::Runtime &) {
            promise->resolve(jsi::Value::undefined());
          });
        });
      });
}

jsi::Value RNNSWindow::setFullScreen(jsi::Runtime &rt, jsi::String windowId,
                                     bool fullscreen) {
  std::string wid = windowId.utf8(rt);
  return createPromiseAsJSIValue(
      rt, [=, this](jsi::Runtime &, std::shared_ptr<Promise> promise) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSString *nsWid = [NSString stringWithUTF8String:wid.c_str()];
          NSWindow *window = [[RNNSWindowHelper shared] windowForId:nsWid];
          if (window) {
            BOOL isFS = (window.styleMask & NSWindowStyleMaskFullScreen) != 0;
            if (fullscreen != isFS) {
              [window toggleFullScreen:nil];
            }
          }
          jsInvoker_->invokeAsync([promise](jsi::Runtime &) {
            promise->resolve(jsi::Value::undefined());
          });
        });
      });
}

jsi::Value RNNSWindow::bringToFront(jsi::Runtime &rt, jsi::String windowId) {
  std::string wid = windowId.utf8(rt);
  return createPromiseAsJSIValue(
      rt, [=, this](jsi::Runtime &, std::shared_ptr<Promise> promise) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSString *nsWid = [NSString stringWithUTF8String:wid.c_str()];
          NSWindow *window = [[RNNSWindowHelper shared] windowForId:nsWid];
          [window orderFront:nil];

          jsInvoker_->invokeAsync([promise](jsi::Runtime &) {
            promise->resolve(jsi::Value::undefined());
          });
        });
      });
}

jsi::Value RNNSWindow::sendToBack(jsi::Runtime &rt, jsi::String windowId) {
  std::string wid = windowId.utf8(rt);
  return createPromiseAsJSIValue(
      rt, [=, this](jsi::Runtime &, std::shared_ptr<Promise> promise) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSString *nsWid = [NSString stringWithUTF8String:wid.c_str()];
          NSWindow *window = [[RNNSWindowHelper shared] windowForId:nsWid];
          [window orderBack:nil];

          jsInvoker_->invokeAsync([promise](jsi::Runtime &) {
            promise->resolve(jsi::Value::undefined());
          });
        });
      });
}

void RNNSWindow::acknowledgeClose(jsi::Runtime &rt, jsi::String windowId,
                                  bool shouldClose) {}

void RNNSWindow::registerWillCloseHandler(jsi::Runtime &rt,
                                          jsi::String windowId) {}

void RNNSWindow::unregisterWillCloseHandler(jsi::Runtime &rt,
                                            jsi::String windowId) {}

} // namespace facebook::react
