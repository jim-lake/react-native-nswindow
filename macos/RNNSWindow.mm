#import "RNNSWindow.h"
#import "RNNSWindowHelper.h"
#import <React/RCTConvert.h>

// ─── C++ Implementation ───

namespace facebook::react {

RNNSWindow::RNNSWindow(std::shared_ptr<CallInvoker> jsInvoker)
    : NativeNSWindowCxxSpec(std::move(jsInvoker)) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [RNNSWindowHelper shared].module = this;
  });
}

RNNSWindow::~RNNSWindow() {
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([RNNSWindowHelper shared].module == this) {
      [RNNSWindowHelper shared].module = nullptr;
    }
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
  BOOL stopShouldClose = p.stopShouldClose.value_or(false);

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

          if (stopShouldClose) {
            [[RNNSWindowHelper shared] setStopShouldClose:YES
                                              forWindowId:windowId];
          }

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
  auto p = NativeNSWindowModifyableWindowPropsBridging<ModifyProps>::fromJs(
      rt, props, jsInvoker_);

  auto toNSString = [](const std::optional<std::string> &s) -> NSString * {
    return s ? [NSString stringWithUTF8String:s->c_str()] : nil;
  };
  auto toNSNumber = [](const std::optional<double> &d) -> NSNumber * {
    return d ? @(*d) : nil;
  };
  auto toNSBool = [](const std::optional<bool> &b) -> NSNumber * {
    return b ? @(*b) : nil;
  };

  NSString *nsWid = [NSString stringWithUTF8String:wid.c_str()];
  NSNumber *nx = toNSNumber(p.x);
  NSNumber *ny = toNSNumber(p.y);
  NSNumber *nWidth = toNSNumber(p.width);
  NSNumber *nHeight = toNSNumber(p.height);
  NSNumber *nMinWidth = toNSNumber(p.minWidth);
  NSNumber *nMinHeight = toNSNumber(p.minHeight);
  NSNumber *nMaxWidth = toNSNumber(p.maxWidth);
  NSNumber *nMaxHeight = toNSNumber(p.maxHeight);
  NSNumber *nCenter = toNSBool(p.center);
  NSString *title = toNSString(p.title);
  NSString *titleBarStyle = toNSString(p.titleBarStyle);
  NSString *vibrancy = toNSString(p.vibrancy);
  NSString *backgroundColor = toNSString(p.backgroundColor);
  NSNumber *nTransparent = toNSBool(p.transparent);
  NSNumber *nHasShadow = toNSBool(p.hasShadow);
  NSNumber *nResizable = toNSBool(p.resizable);
  NSNumber *nMovable = toNSBool(p.movable);
  NSNumber *nMinimizable = toNSBool(p.minimizable);
  NSNumber *nClosable = toNSBool(p.closable);
  NSNumber *nZoomable = toNSBool(p.zoomable);
  NSNumber *nAlwaysOnTop = toNSBool(p.alwaysOnTop);
  NSString *level = toNSString(p.level);
  NSNumber *nShow = toNSBool(p.show);
  NSNumber *nFocusOnCreate = toNSBool(p.focusOnCreate);
  NSString *autoSaveFrame = toNSString(p.autoSaveFrame);
  NSNumber *nStopShouldClose = toNSBool(p.stopShouldClose);

  return createPromiseAsJSIValue(
      rt, [=, this](jsi::Runtime &, std::shared_ptr<Promise> promise) {
        dispatch_async(dispatch_get_main_queue(), ^{
          BOOL success =
              [[RNNSWindowHelper shared] modifyWindow:nsWid
                                                    x:nx
                                                    y:ny
                                                width:nWidth
                                               height:nHeight
                                             minWidth:nMinWidth
                                            minHeight:nMinHeight
                                             maxWidth:nMaxWidth
                                            maxHeight:nMaxHeight
                                               center:nCenter
                                                title:title
                                        titleBarStyle:titleBarStyle
                                             vibrancy:vibrancy
                                      backgroundColor:backgroundColor
                                          transparent:nTransparent
                                            hasShadow:nHasShadow
                                            resizable:nResizable
                                              movable:nMovable
                                          minimizable:nMinimizable
                                             closable:nClosable
                                             zoomable:nZoomable
                                          alwaysOnTop:nAlwaysOnTop
                                                level:level
                                                 show:nShow
                                        focusOnCreate:nFocusOnCreate
                                        autoSaveFrame:autoSaveFrame
                                      stopShouldClose:nStopShouldClose];

          if (!success) {
            jsInvoker_->invokeAsync([promise, wid](jsi::Runtime &) {
              promise->reject("Window not found: " + wid);
            });
            return;
          }

          jsInvoker_->invokeAsync([promise](jsi::Runtime &) {
            promise->resolve(jsi::Value::undefined());
          });
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
      bool isOccluded =
          (window.occlusionState & NSWindowOcclusionStateVisible) == 0;
      double scaleFactor = [window backingScaleFactor];
      std::string nameStr = [name UTF8String];
      double x = frame.origin.x;
      double y = frame.origin.y;
      double w = frame.size.width;
      double h = frame.size.height;

      // Screen frame (nullable)
      bool hasScreen = (window.screen != nil);
      double sx = 0, sy = 0, sw = 0, sh = 0;
      if (hasScreen) {
        NSRect sf = window.screen.frame;
        sx = sf.origin.x;
        sy = sf.origin.y;
        sw = sf.size.width;
        sh = sf.size.height;
      }

      jsInvoker_->invokeAsync([promise, wid, nameStr, x, y, w, h, isKey, isMini,
                               isFS, isVis, isOccluded, scaleFactor, hasScreen,
                               sx, sy, sw, sh](jsi::Runtime &rt2) {
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
        obj.setProperty(rt2, "isOccluded", isOccluded);
        obj.setProperty(rt2, "backingScaleFactor", scaleFactor);
        if (hasScreen) {
          auto screen = jsi::Object(rt2);
          screen.setProperty(rt2, "x", sx);
          screen.setProperty(rt2, "y", sy);
          screen.setProperty(rt2, "width", sw);
          screen.setProperty(rt2, "height", sh);
          obj.setProperty(rt2, "screen", std::move(screen));
        } else {
          obj.setProperty(rt2, "screen", jsi::Value::null());
        }
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

jsi::Value RNNSWindow::getScreenInfo(jsi::Runtime &rt) {
  return createPromiseAsJSIValue(
      rt, [this](jsi::Runtime &, std::shared_ptr<Promise> promise) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSArray<NSScreen *> *screens = [NSScreen screens];

          // Compute total bounding rect across all screens
          double minX = CGFLOAT_MAX, minY = CGFLOAT_MAX;
          double maxX = -CGFLOAT_MAX, maxY = -CGFLOAT_MAX;
          double minVX = CGFLOAT_MAX, minVY = CGFLOAT_MAX;
          double maxVX = -CGFLOAT_MAX, maxVY = -CGFLOAT_MAX;

          struct ScreenData {
            double fx, fy, fw, fh;
            double vx, vy, vw, vh;
          };
          std::vector<ScreenData> screenData;

          for (NSScreen *s in screens) {
            NSRect f = s.frame;
            NSRect v = s.visibleFrame;
            screenData.push_back({f.origin.x, f.origin.y, f.size.width,
                                  f.size.height, v.origin.x, v.origin.y,
                                  v.size.width, v.size.height});
            minX = std::min(minX, f.origin.x);
            minY = std::min(minY, f.origin.y);
            maxX = std::max(maxX, f.origin.x + f.size.width);
            maxY = std::max(maxY, f.origin.y + f.size.height);
            minVX = std::min(minVX, v.origin.x);
            minVY = std::min(minVY, v.origin.y);
            maxVX = std::max(maxVX, v.origin.x + v.size.width);
            maxVY = std::max(maxVY, v.origin.y + v.size.height);
          }

          double totalX = minX, totalY = minY;
          double totalW = maxX - minX, totalH = maxY - minY;
          double totalVX = minVX, totalVY = minVY;
          double totalVW = maxVX - minVX, totalVH = maxVY - minVY;

          // Main screen frame
          NSRect mainFrame = NSScreen.mainScreen.frame;
          double mx = mainFrame.origin.x, my = mainFrame.origin.y;
          double mw = mainFrame.size.width, mh = mainFrame.size.height;

          jsInvoker_->invokeAsync([promise, screenData, totalX, totalY, totalW,
                                   totalH, totalVX, totalVY, totalVW, totalVH,
                                   mx, my, mw, mh](jsi::Runtime &rt2) {
            auto obj = jsi::Object(rt2);

            auto total = jsi::Object(rt2);
            total.setProperty(rt2, "x", totalX);
            total.setProperty(rt2, "y", totalY);
            total.setProperty(rt2, "width", totalW);
            total.setProperty(rt2, "height", totalH);
            obj.setProperty(rt2, "total", std::move(total));

            auto totalVis = jsi::Object(rt2);
            totalVis.setProperty(rt2, "x", totalVX);
            totalVis.setProperty(rt2, "y", totalVY);
            totalVis.setProperty(rt2, "width", totalVW);
            totalVis.setProperty(rt2, "height", totalVH);
            obj.setProperty(rt2, "totalVisibleFrame", std::move(totalVis));

            auto screensArr = jsi::Array(rt2, screenData.size());
            for (size_t i = 0; i < screenData.size(); i++) {
              auto &sd = screenData[i];
              auto sObj = jsi::Object(rt2);

              auto frame = jsi::Object(rt2);
              frame.setProperty(rt2, "x", sd.fx);
              frame.setProperty(rt2, "y", sd.fy);
              frame.setProperty(rt2, "width", sd.fw);
              frame.setProperty(rt2, "height", sd.fh);
              sObj.setProperty(rt2, "frame", std::move(frame));

              auto vis = jsi::Object(rt2);
              vis.setProperty(rt2, "x", sd.vx);
              vis.setProperty(rt2, "y", sd.vy);
              vis.setProperty(rt2, "width", sd.vw);
              vis.setProperty(rt2, "height", sd.vh);
              sObj.setProperty(rt2, "visibleFrame", std::move(vis));

              screensArr.setValueAtIndex(rt2, i, std::move(sObj));
            }
            obj.setProperty(rt2, "screens", std::move(screensArr));

            auto main = jsi::Object(rt2);
            main.setProperty(rt2, "x", mx);
            main.setProperty(rt2, "y", my);
            main.setProperty(rt2, "width", mw);
            main.setProperty(rt2, "height", mh);
            obj.setProperty(rt2, "main", std::move(main));

            promise->resolve(std::move(obj));
          });
        });
      });
}

} // namespace facebook::react
