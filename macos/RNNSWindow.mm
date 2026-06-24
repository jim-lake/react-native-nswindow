#import "RNNSWindow.h"

namespace facebook::react {

RNNSWindow::RNNSWindow(std::shared_ptr<CallInvoker> jsInvoker)
    : NativeNSWindowCxxSpec(std::move(jsInvoker)) {}

jsi::Value RNNSWindow::addWindow(jsi::Runtime &rt, jsi::Object props) {
  return jsi::Value::undefined();
}

jsi::Value RNNSWindow::closeWindow(jsi::Runtime &rt, jsi::String windowId) {
  return jsi::Value::undefined();
}

jsi::Value RNNSWindow::modifyWindow(jsi::Runtime &rt, jsi::String windowId, jsi::Object props) {
  return jsi::Value::undefined();
}

jsi::Value RNNSWindow::listWindows(jsi::Runtime &rt) {
  return jsi::Value::undefined();
}

jsi::Value RNNSWindow::getWindowState(jsi::Runtime &rt, jsi::String windowId) {
  return jsi::Value::undefined();
}

jsi::Value RNNSWindow::focusWindow(jsi::Runtime &rt, jsi::String windowId) {
  return jsi::Value::undefined();
}

jsi::Value RNNSWindow::hideWindow(jsi::Runtime &rt, jsi::String windowId) {
  return jsi::Value::undefined();
}

jsi::Value RNNSWindow::showWindow(jsi::Runtime &rt, jsi::String windowId) {
  return jsi::Value::undefined();
}

jsi::Value RNNSWindow::minimizeWindow(jsi::Runtime &rt, jsi::String windowId) {
  return jsi::Value::undefined();
}

jsi::Value RNNSWindow::deminimizeWindow(jsi::Runtime &rt, jsi::String windowId) {
  return jsi::Value::undefined();
}

jsi::Value RNNSWindow::setFullScreen(jsi::Runtime &rt, jsi::String windowId, bool fullscreen) {
  return jsi::Value::undefined();
}

jsi::Value RNNSWindow::bringToFront(jsi::Runtime &rt, jsi::String windowId) {
  return jsi::Value::undefined();
}

jsi::Value RNNSWindow::sendToBack(jsi::Runtime &rt, jsi::String windowId) {
  return jsi::Value::undefined();
}

void RNNSWindow::acknowledgeClose(jsi::Runtime &rt, jsi::String windowId, bool shouldClose) {
}

void RNNSWindow::registerWillCloseHandler(jsi::Runtime &rt, jsi::String windowId) {
}

void RNNSWindow::unregisterWillCloseHandler(jsi::Runtime &rt, jsi::String windowId) {
}

} // namespace facebook::react
