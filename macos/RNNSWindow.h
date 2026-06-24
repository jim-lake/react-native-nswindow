#pragma once

#include "RNNSWindowSpecJSI.h"
#include <ReactCommon/TurboModuleUtils.h>

namespace facebook::react {

// Concrete types from codegen structs
using WindowProps = NativeNSWindowWindowProps<
    std::optional<double>, std::optional<double>, std::optional<double>,
    std::optional<double>, std::optional<double>, std::optional<double>,
    std::optional<double>, std::optional<double>, std::optional<bool>,
    std::optional<std::string>, std::optional<std::string>,
    std::optional<std::string>, std::optional<std::string>, std::optional<bool>,
    std::optional<bool>, std::optional<bool>, std::optional<bool>,
    std::optional<bool>, std::optional<bool>, std::optional<bool>,
    std::optional<bool>, std::optional<std::string>, std::optional<bool>,
    std::optional<bool>, std::optional<std::string>, std::optional<bool>,
    std::string, std::string, jsi::Object>;

using ModifyProps = NativeNSWindowModifyableWindowProps<
    std::optional<double>, std::optional<double>, std::optional<double>,
    std::optional<double>, std::optional<double>, std::optional<double>,
    std::optional<double>, std::optional<double>, std::optional<bool>,
    std::optional<std::string>, std::optional<std::string>,
    std::optional<std::string>, std::optional<std::string>, std::optional<bool>,
    std::optional<bool>, std::optional<bool>, std::optional<bool>,
    std::optional<bool>, std::optional<bool>, std::optional<bool>,
    std::optional<bool>, std::optional<std::string>, std::optional<bool>,
    std::optional<bool>, std::optional<std::string>, std::optional<bool>>;

// Concrete types for events
using WindowMovePayload =
    NativeNSWindowWindowMovePayload<std::string, double, double>;
using WindowResizePayload =
    NativeNSWindowWindowResizePayload<std::string, double, double>;
using WindowStateResult =
    NativeNSWindowWindowState<std::string, std::string, double, double, double,
                              double, bool, bool, bool, bool>;

} // namespace facebook::react

// bridging support for event payload structs
namespace facebook::react {

template <> struct Bridging<WindowMovePayload> {
  static WindowMovePayload
  fromJs(jsi::Runtime &rt, const jsi::Object &value,
         const std::shared_ptr<CallInvoker> &jsInvoker) {
    return NativeNSWindowWindowMovePayloadBridging<WindowMovePayload>::fromJs(
        rt, value, jsInvoker);
  }

  static jsi::Object toJs(jsi::Runtime &rt, const WindowMovePayload &value,
                          const std::shared_ptr<CallInvoker> &jsInvoker) {
    return NativeNSWindowWindowMovePayloadBridging<WindowMovePayload>::toJs(
        rt, value, jsInvoker);
  }
};

template <> struct Bridging<WindowResizePayload> {
  static WindowResizePayload
  fromJs(jsi::Runtime &rt, const jsi::Object &value,
         const std::shared_ptr<CallInvoker> &jsInvoker) {
    return NativeNSWindowWindowResizePayloadBridging<
        WindowResizePayload>::fromJs(rt, value, jsInvoker);
  }

  static jsi::Object toJs(jsi::Runtime &rt, const WindowResizePayload &value,
                          const std::shared_ptr<CallInvoker> &jsInvoker) {
    return NativeNSWindowWindowResizePayloadBridging<WindowResizePayload>::toJs(
        rt, value, jsInvoker);
  }
};

} // namespace facebook::react

namespace facebook::react {

class RNNSWindow : public NativeNSWindowCxxSpec<RNNSWindow> {
public:
  RNNSWindow(std::shared_ptr<CallInvoker> jsInvoker);
  ~RNNSWindow();

  using NativeNSWindowCxxSpec<RNNSWindow>::emitOnWindowClose;
  using NativeNSWindowCxxSpec<RNNSWindow>::emitOnWindowWillClose;
  using NativeNSWindowCxxSpec<RNNSWindow>::emitOnWindowMove;
  using NativeNSWindowCxxSpec<RNNSWindow>::emitOnWindowResize;
  using NativeNSWindowCxxSpec<RNNSWindow>::emitOnWindowFocus;
  using NativeNSWindowCxxSpec<RNNSWindow>::emitOnWindowBlur;
  using NativeNSWindowCxxSpec<RNNSWindow>::emitOnWindowMinimize;
  using NativeNSWindowCxxSpec<RNNSWindow>::emitOnWindowDeminimize;
  using NativeNSWindowCxxSpec<RNNSWindow>::emitOnWindowEnterFullScreen;
  using NativeNSWindowCxxSpec<RNNSWindow>::emitOnWindowExitFullScreen;

  jsi::Value addWindow(jsi::Runtime &rt, jsi::Object props);
  jsi::Value closeWindow(jsi::Runtime &rt, jsi::String windowId);
  jsi::Value modifyWindow(jsi::Runtime &rt, jsi::String windowId,
                          jsi::Object props);

  jsi::Value listWindows(jsi::Runtime &rt);
  jsi::Value getWindowState(jsi::Runtime &rt, jsi::String windowId);

  jsi::Value focusWindow(jsi::Runtime &rt, jsi::String windowId);
  jsi::Value hideWindow(jsi::Runtime &rt, jsi::String windowId);
  jsi::Value showWindow(jsi::Runtime &rt, jsi::String windowId);

  jsi::Value minimizeWindow(jsi::Runtime &rt, jsi::String windowId);
  jsi::Value deminimizeWindow(jsi::Runtime &rt, jsi::String windowId);
  jsi::Value setFullScreen(jsi::Runtime &rt, jsi::String windowId,
                           bool fullscreen);

  jsi::Value bringToFront(jsi::Runtime &rt, jsi::String windowId);
  jsi::Value sendToBack(jsi::Runtime &rt, jsi::String windowId);
};

} // namespace facebook::react
