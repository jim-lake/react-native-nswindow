# react-native-nswindow

Multi-window support for React Native macOS. Create, modify, close, and observe native `NSWindow` instances from JavaScript.

## Requirements

- React Native macOS >= 0.81
- macOS deployment target >= 14.0
- New Architecture (TurboModules) enabled

## Installation

```bash
npm install react-native-nswindow
cd macos && pod install
```

## Usage

```tsx
import NSWindowModule from 'react-native-nswindow';
import { AppRegistry } from 'react-native';

// Register a component to render in the new window
function MyWindow() {
  return <Text>Hello from a new window!</Text>;
}
AppRegistry.registerComponent('MyWindow', () => MyWindow);

// Create a window
const windowId = await NSWindowModule.addWindow({
  componentName: 'MyWindow',
  windowName: 'my-window',
  initialProps: {},
  title: 'My Window',
  width: 600,
  height: 400,
});

// Modify it
await NSWindowModule.modifyWindow(windowId, {
  title: 'Updated Title',
  backgroundColor: '#1e1e1e',
  vibrancy: 'sidebar',
});

// Listen for events
const sub = NSWindowModule.onWindowClose((id) => {
  console.log('Window closed:', id);
});
sub.remove(); // cleanup
```

## API

### Methods

| Method | Description |
|--------|-------------|
| `addWindow(props: WindowProps)` | Create a new window. Returns its ID. |
| `closeWindow(windowId)` | Close a window. |
| `modifyWindow(windowId, props)` | Modify window properties. |
| `listWindows()` | List all tracked window IDs. |
| `getWindowState(windowId)` | Get position, size, and state flags. |
| `focusWindow(windowId)` | Make window key and bring to front. |
| `hideWindow(windowId)` | Hide (order out) a window. |
| `showWindow(windowId)` | Show (order front) a window. |
| `minimizeWindow(windowId)` | Minimize to dock. |
| `deminimizeWindow(windowId)` | Restore from dock. |
| `setFullScreen(windowId, bool)` | Enter/exit full screen. |
| `bringToFront(windowId)` | Order front. |
| `sendToBack(windowId)` | Order back. |

### Window Props

All properties are optional except `componentName`, `windowName`, and `initialProps` (on `addWindow`).

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `x`, `y` | number | 100 | Window origin |
| `width`, `height` | number | 400×300 | Window size |
| `minWidth`, `minHeight` | number | — | Minimum size constraints |
| `maxWidth`, `maxHeight` | number | — | Maximum size constraints |
| `center` | boolean | false | Center on screen |
| `title` | string | windowName | Title bar text |
| `titleBarStyle` | string | 'default' | 'default' \| 'hidden' \| 'hiddenInset' \| 'transparent' |
| `vibrancy` | string | 'none' | 'none' \| 'sidebar' \| 'menu' \| 'popover' \| 'fullScreenUI' \| 'underWindowBackground' \| 'hudWindow' |
| `backgroundColor` | string | — | Hex color (e.g. '#ff0000') |
| `transparent` | boolean | false | Fully transparent background |
| `hasShadow` | boolean | true | Window shadow |
| `resizable` | boolean | true | Allow resize |
| `movable` | boolean | true | Allow drag |
| `minimizable` | boolean | true | Show minimize button |
| `closable` | boolean | true | Show close button |
| `zoomable` | boolean | true | Enable zoom button |
| `alwaysOnTop` | boolean | false | Float above other windows |
| `level` | string | 'normal' | 'normal' \| 'floating' \| 'modalPanel' \| 'mainMenu' \| 'statusBar' \| 'screenSaver' |
| `show` | boolean | true | Show immediately |
| `focusOnCreate` | boolean | true | Make key on show |
| `autoSaveFrame` | string | — | Persist frame position across launches |
| `stopShouldClose` | boolean | false | Intercept close (window stays open) |

### Events

| Event | Payload | Description |
|-------|---------|-------------|
| `onWindowClose` | windowId | Window was closed |
| `onWindowWillClose` | windowId | Close was attempted (fires even if blocked) |
| `onWindowFocus` | windowId | Became key window |
| `onWindowBlur` | windowId | Resigned key window |
| `onWindowMove` | `{ windowId, x, y }` | Window moved |
| `onWindowResize` | `{ windowId, width, height }` | Window resized |
| `onWindowMinimize` | windowId | Minimized to dock |
| `onWindowDeminimize` | windowId | Restored from dock |
| `onWindowEnterFullScreen` | windowId | Entered full screen |
| `onWindowExitFullScreen` | windowId | Exited full screen |
| `onWindowOcclusionStateChange` | `{ windowId, isVisible }` | Window occlusion state changed (visible/occluded) |

## How It Works

This is a C++ TurboModule (CxxTurboModule). An ObjC singleton (`RNNSWindowHelper`) manages the window dictionary, acts as `NSWindowDelegate`, and observes `NSNotificationCenter` for all window events. Window operations dispatch to the main thread; promises resolve via the JS invoker.

## License

MIT
