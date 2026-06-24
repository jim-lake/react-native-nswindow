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
    std::optional<bool>, std::optional<std::string>, std::string, std::string,
    jsi::Object>;

using ModifyProps = NativeNSWindowModifyableWindowProps<
    std::optional<double>, std::optional<double>, std::optional<double>,
    std::optional<double>, std::optional<double>, std::optional<double>,
    std::optional<double>, std::optional<double>, std::optional<bool>,
    std::optional<std::string>, std::optional<std::string>,
    std::optional<std::string>, std::optional<std::string>, std::optional<bool>,
    std::optional<bool>, std::optional<bool>, std::optional<bool>,
    std::optional<bool>, std::optional<bool>, std::optional<bool>,
    std::optional<bool>, std::optional<std::string>, std::optional<bool>,
    std::optional<bool>, std::optional<std::string>>;

// Concrete types for events
using WindowMovePayload =
    NativeNSWindowWindowMovePayload<std::string, double, double>;
using WindowResizePayload =
    NativeNSWindowWindowResizePayload<std::string, double, double>;
using WindowStateResult =
    NativeNSWindowWindowState<std::string, std::string, double, double, double,
                              double, bool, bool, bool, bool>;

class RNNSWindow : public NativeNSWindowCxxSpec<RNNSWindow> {
public:
  RNNSWindow(std::shared_ptr<CallInvoker> jsInvoker);

  using NativeNSWindowCxxSpec<RNNSWindow>::emitOnWindowClose;

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

  void acknowledgeClose(jsi::Runtime &rt, jsi::String windowId,
                        bool shouldClose);
  void registerWillCloseHandler(jsi::Runtime &rt, jsi::String windowId);
  void unregisterWillCloseHandler(jsi::Runtime &rt, jsi::String windowId);
};

} // namespace facebook::react
