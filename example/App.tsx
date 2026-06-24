import React, { useState, useEffect } from 'react';
import {
  AppRegistry,
  View,
  Text,
  Button,
  StyleSheet,
  ScrollView,
  TextInput,
} from 'react-native';
import NSWindowModule from 'react-native-nswindow';
import type {
  WindowMovePayload,
  WindowResizePayload,
} from 'react-native-nswindow';

console.log('[NSWindowExample] App.tsx loading...');
console.log('[NSWindowExample] NSWindowModule:', NSWindowModule);
console.log(
  '[NSWindowExample] NSWindowModule keys:',
  Object.getOwnPropertyNames(NSWindowModule)
);

// ─── Secondary window components ───

function NotesWindow() {
  console.log('[NotesWindow] Rendering');
  const [text, setText] = useState('');
  return (
    <View style={styles.container}>
      <Text style={styles.title}>📝 Notes</Text>
      <TextInput
        style={styles.textInput}
        multiline
        value={text}
        onChangeText={(v) => {
          console.log('[NotesWindow] onChangeText:', v.length, 'chars');
          setText(v);
        }}
        placeholder='Type notes here...'
      />
    </View>
  );
}

function ColorWindow({ color = '#ff6b6b' }: { color?: string }) {
  console.log('[ColorWindow] Rendering with color:', color);
  return (
    <View style={[styles.container, { backgroundColor: color }]}>
      <Text style={styles.title}>🎨 Color Window</Text>
      <Text style={styles.subtitle}>Background: {color}</Text>
    </View>
  );
}

function MiniWindow() {
  console.log('[MiniWindow] Rendering');
  return (
    <View style={[styles.container, { backgroundColor: '#2d3436' }]}>
      <Text style={[styles.title, { color: '#fff' }]}>🔲 Mini</Text>
    </View>
  );
}

// ─── Main window ───

function App() {
  console.log('[App] Rendering main window');
  const [log, setLog] = useState<string[]>([]);
  const [windows, setWindows] = useState<string[]>([]);

  const appendLog = (msg: string) => {
    console.log('[App Event]', msg);
    setLog((prev) =>
      [`[${new Date().toLocaleTimeString()}] ${msg}`, ...prev].slice(0, 50)
    );
  };

  useEffect(() => {
    console.log('[App] useEffect - setting up event listeners');
    const subs = [
      NSWindowModule.onWindowClose((windowId: string) => {
        console.log('[App] onWindowClose:', windowId);
        appendLog(`close: ${windowId.slice(0, 8)}`);
      }),
      NSWindowModule.onWindowWillClose((windowId: string) => {
        console.log('[App] onWindowWillClose:', windowId);
        appendLog(`willClose: ${windowId.slice(0, 8)}`);
      }),
      NSWindowModule.onWindowFocus((windowId: string) => {
        console.log('[App] onWindowFocus:', windowId);
        appendLog(`focus: ${windowId.slice(0, 8)}`);
      }),
      NSWindowModule.onWindowBlur((windowId: string) => {
        console.log('[App] onWindowBlur:', windowId);
        appendLog(`blur: ${windowId.slice(0, 8)}`);
      }),
      NSWindowModule.onWindowMove((p: WindowMovePayload) => {
        console.log('[App] onWindowMove:', p);
        appendLog(
          `move: ${p.windowId.slice(0, 8)} → (${Math.round(p.x)},${Math.round(
            p.y
          )})`
        );
      }),
      NSWindowModule.onWindowResize((p: WindowResizePayload) => {
        console.log('[App] onWindowResize:', p);
        appendLog(
          `resize: ${p.windowId.slice(0, 8)} → ${Math.round(
            p.width
          )}x${Math.round(p.height)}`
        );
      }),
      NSWindowModule.onWindowMinimize((windowId: string) => {
        console.log('[App] onWindowMinimize:', windowId);
        appendLog(`minimize: ${windowId.slice(0, 8)}`);
      }),
      NSWindowModule.onWindowDeminimize((windowId: string) => {
        console.log('[App] onWindowDeminimize:', windowId);
        appendLog(`deminimize: ${windowId.slice(0, 8)}`);
      }),
      NSWindowModule.onWindowEnterFullScreen((windowId: string) => {
        console.log('[App] onWindowEnterFullScreen:', windowId);
        appendLog(`enterFS: ${windowId.slice(0, 8)}`);
      }),
      NSWindowModule.onWindowExitFullScreen((windowId: string) => {
        console.log('[App] onWindowExitFullScreen:', windowId);
        appendLog(`exitFS: ${windowId.slice(0, 8)}`);
      }),
    ];
    console.log('[App] Event listeners registered:', subs.length);
    return () => {
      console.log('[App] Cleaning up event listeners');
      subs.forEach((s) => s.remove());
    };
  }, []);

  const refreshWindows = async () => {
    console.log('[App] refreshWindows called');
    try {
      const ids = await NSWindowModule.listWindows();
      console.log('[App] refreshWindows result:', ids);
      setWindows(ids);
      appendLog(`listWindows: ${ids.length} open`);
    } catch (e: any) {
      console.error('[App] refreshWindows error:', e);
      appendLog(`ERROR listWindows: ${e.message}`);
    }
  };

  const openNotes = async () => {
    console.log('[App] openNotes called');
    try {
      const id = await NSWindowModule.addWindow({
        componentName: 'NotesWindow',
        windowName: 'notes',
        initialProps: {},
        title: 'Notes',
        width: 400,
        height: 300,
      });
      console.log('[App] opened notes window:', id);
      appendLog(`opened notes: ${id.slice(0, 8)}`);
      refreshWindows();
    } catch (e: any) {
      console.error('[App] openNotes error:', e);
      appendLog(`ERROR openNotes: ${e.message}`);
    }
  };

  const openColor = async () => {
    console.log('[App] openColor called');
    try {
      const colors = ['#ff6b6b', '#a29bfe', '#00cec9', '#fdcb6e', '#6c5ce7'];
      const color = colors[Math.floor(Math.random() * colors.length)];
      console.log('[App] opening color window with color:', color);
      const id = await NSWindowModule.addWindow({
        componentName: 'ColorWindow',
        windowName: 'color',
        title: `Color: ${color}`,
        width: 300,
        height: 200,
        initialProps: { color },
        titleBarStyle: 'hiddenInset',
        vibrancy: 'popover',
      });
      console.log('[App] opened color window:', id, 'color:', color);
      appendLog(`opened color(${color}): ${id.slice(0, 8)}`);
      refreshWindows();
    } catch (e: any) {
      console.error('[App] openColor error:', e);
      appendLog(`ERROR openColor: ${e.message}`);
    }
  };

  const openMini = async () => {
    console.log('[App] openMini called');
    try {
      const id = await NSWindowModule.addWindow({
        componentName: 'MiniWindow',
        windowName: 'mini',
        initialProps: {},
        title: 'Mini',
        width: 150,
        height: 100,
        minWidth: 100,
        minHeight: 80,
        maxWidth: 300,
        maxHeight: 200,
        resizable: true,
        alwaysOnTop: true,
      });
      console.log('[App] opened mini window:', id);
      appendLog(`opened mini: ${id.slice(0, 8)}`);
      refreshWindows();
    } catch (e: any) {
      console.error('[App] openMini error:', e);
      appendLog(`ERROR openMini: ${e.message}`);
    }
  };

  const openHidden = async () => {
    console.log('[App] openHidden called');
    try {
      const id = await NSWindowModule.addWindow({
        componentName: 'NotesWindow',
        windowName: 'hidden-test',
        initialProps: {},
        title: 'Hidden Window',
        show: false,
        width: 400,
        height: 300,
      });
      console.log('[App] created hidden window:', id);
      appendLog(`created hidden: ${id.slice(0, 8)} — use Show to reveal`);
      refreshWindows();
    } catch (e: any) {
      console.error('[App] openHidden error:', e);
      appendLog(`ERROR openHidden: ${e.message}`);
    }
  };

  const firstId = windows[windows.length - 1];

  const safeCall = async (name: string, fn: () => Promise<any>) => {
    console.log(`[App] safeCall: ${name}, windowId:`, firstId);
    try {
      const result = await fn();
      console.log(`[App] ${name} result:`, result);
      appendLog(`${name} (${firstId?.slice(0, 8) ?? 'none'}): success`);
      return result;
    } catch (e: any) {
      console.error(`[App] ${name} error:`, e);
      appendLog(
        `ERROR ${name} (${firstId?.slice(0, 8) ?? 'none'}): ${e.message}`
      );
    }
  };

  return (
    <ScrollView
      style={styles.scroll}
      contentContainerStyle={styles.scrollContent}
    >
      <Text style={styles.header}>NSWindow Example</Text>

      <Text style={styles.section}>Create Windows</Text>
      <View style={styles.row}>
        <Button
          title='📝 Notes'
          onPress={() => {
            console.log('[App] Button press: Notes');
            openNotes();
          }}
        />
        <Button
          title='🎨 Color'
          onPress={() => {
            console.log('[App] Button press: Color');
            openColor();
          }}
        />
        <Button
          title='🔲 Mini (On Top)'
          onPress={() => {
            console.log('[App] Button press: Mini');
            openMini();
          }}
        />
        <Button
          title='👻 Hidden'
          onPress={() => {
            console.log('[App] Button press: Hidden');
            openHidden();
          }}
        />
      </View>

      <Text style={styles.section}>
        Window Actions {firstId ? `(on ${firstId.slice(0, 8)})` : '(none open)'}
      </Text>
      <View style={styles.row}>
        <Button
          title='List Windows'
          onPress={async () => {
            try {
              const ids = await NSWindowModule.listWindows();
              console.log('[App] listWindows:', ids);
              appendLog(
                `listWindows: [${ids
                  .map((id: string) => id.slice(0, 8))
                  .join(', ')}]`
              );
              setWindows(ids);
            } catch (e: any) {
              console.error('[App] listWindows error:', e);
              appendLog(`ERROR listWindows: ${e.message}`);
            }
          }}
        />
        <Button
          title='Close'
          onPress={() =>
            safeCall('closeWindow', () => NSWindowModule.closeWindow(firstId))
          }
        />
        <Button
          title='Focus'
          onPress={() =>
            safeCall('focusWindow', () => NSWindowModule.focusWindow(firstId))
          }
        />
        <Button
          title='Hide'
          onPress={() =>
            safeCall('hideWindow', () => NSWindowModule.hideWindow(firstId))
          }
        />
        <Button
          title='Show'
          onPress={() =>
            safeCall('showWindow', () => NSWindowModule.showWindow(firstId))
          }
        />
        <Button
          title='Minimize'
          onPress={() =>
            safeCall('minimizeWindow', () =>
              NSWindowModule.minimizeWindow(firstId)
            )
          }
        />
        <Button
          title='Deminimize'
          onPress={() =>
            safeCall('deminimizeWindow', () =>
              NSWindowModule.deminimizeWindow(firstId)
            )
          }
        />
        <Button
          title='FullScreen On'
          onPress={() =>
            safeCall('setFullScreen(true)', () =>
              NSWindowModule.setFullScreen(firstId, true)
            )
          }
        />
        <Button
          title='FullScreen Off'
          onPress={() =>
            safeCall('setFullScreen(false)', () =>
              NSWindowModule.setFullScreen(firstId, false)
            )
          }
        />
        <Button
          title='Bring Front'
          onPress={() =>
            safeCall('bringToFront', () => NSWindowModule.bringToFront(firstId))
          }
        />
        <Button
          title='Send Back'
          onPress={() =>
            safeCall('sendToBack', () => NSWindowModule.sendToBack(firstId))
          }
        />
        <Button
          title='Get State'
          onPress={async () => {
            if (!firstId) return;
            try {
              const state = await NSWindowModule.getWindowState(firstId);
              console.log('[App] getWindowState:', state);
              appendLog(`getState: ${JSON.stringify(state)}`);
            } catch (e: any) {
              console.error('[App] getWindowState error:', e);
              appendLog(`ERROR getWindowState: ${e.message}`);
            }
          }}
        />
      </View>

      <Text style={styles.section}>Modify Last Window</Text>
      <View style={styles.row}>
        <Button
          title='Resize 600x400'
          onPress={() => {
            const payload = { width: 600, height: 400 };
            console.log('[App] modifyWindow:', firstId, payload);
            appendLog(
              `modify ${firstId?.slice(0, 8)}: ${JSON.stringify(payload)}`
            );
            safeCall('modifyWindow(size)', () =>
              NSWindowModule.modifyWindow(firstId, payload)
            );
          }}
        />
        <Button
          title='Move (100,100)'
          onPress={() => {
            const payload = { x: 100, y: 100 };
            console.log('[App] modifyWindow:', firstId, payload);
            appendLog(
              `modify ${firstId?.slice(0, 8)}: ${JSON.stringify(payload)}`
            );
            safeCall('modifyWindow(pos)', () =>
              NSWindowModule.modifyWindow(firstId, payload)
            );
          }}
        />
        <Button
          title='Title: Modified'
          onPress={() => {
            const payload = { title: 'Modified!' };
            console.log('[App] modifyWindow:', firstId, payload);
            appendLog(
              `modify ${firstId?.slice(0, 8)}: ${JSON.stringify(payload)}`
            );
            safeCall('modifyWindow(title)', () =>
              NSWindowModule.modifyWindow(firstId, payload)
            );
          }}
        />
        <Button
          title='Lock Resize'
          onPress={() => {
            const payload = { resizable: false };
            console.log('[App] modifyWindow:', firstId, payload);
            appendLog(
              `modify ${firstId?.slice(0, 8)}: ${JSON.stringify(payload)}`
            );
            safeCall('modifyWindow(noResize)', () =>
              NSWindowModule.modifyWindow(firstId, payload)
            );
          }}
        />
        <Button
          title='Unlock Resize'
          onPress={() => {
            const payload = { resizable: true };
            console.log('[App] modifyWindow:', firstId, payload);
            appendLog(
              `modify ${firstId?.slice(0, 8)}: ${JSON.stringify(payload)}`
            );
            safeCall('modifyWindow(resize)', () =>
              NSWindowModule.modifyWindow(firstId, payload)
            );
          }}
        />
        <Button
          title='Prevent Close'
          onPress={() => {
            const payload = { stopShouldClose: true };
            console.log('[App] modifyWindow:', firstId, payload);
            appendLog(
              `modify ${firstId?.slice(0, 8)}: ${JSON.stringify(payload)}`
            );
            safeCall('modifyWindow(preventClose)', () =>
              NSWindowModule.modifyWindow(firstId, payload)
            );
          }}
        />
        <Button
          title='Unprevent Close'
          onPress={() => {
            const payload = { stopShouldClose: false };
            console.log('[App] modifyWindow:', firstId, payload);
            appendLog(
              `modify ${firstId?.slice(0, 8)}: ${JSON.stringify(payload)}`
            );
            safeCall('modifyWindow(unpreventClose)', () =>
              NSWindowModule.modifyWindow(firstId, payload)
            );
          }}
        />
      </View>

      <Text style={styles.section}>Event Log</Text>
      <View style={styles.logBox}>
        {log.map((entry, i) => (
          <Text key={i} style={styles.logEntry}>
            {entry}
          </Text>
        ))}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  scroll: { flex: 1, backgroundColor: '#f5f5f5' },
  scrollContent: { padding: 20 },
  header: { fontSize: 24, fontWeight: 'bold', marginBottom: 16 },
  section: { fontSize: 16, fontWeight: '600', marginTop: 16, marginBottom: 8 },
  row: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  container: {
    flex: 1,
    padding: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: { fontSize: 20, fontWeight: 'bold' },
  subtitle: { fontSize: 14, marginTop: 8, opacity: 0.7 },
  textInput: {
    flex: 1,
    width: '100%',
    marginTop: 12,
    padding: 10,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 6,
    fontSize: 14,
    textAlignVertical: 'top',
  },
  logBox: {
    marginTop: 8,
    padding: 10,
    backgroundColor: '#1e1e1e',
    borderRadius: 6,
    maxHeight: 200,
  },
  logEntry: {
    fontSize: 11,
    fontFamily: 'Menlo',
    color: '#0f0',
    marginBottom: 2,
  },
});

// ─── Register secondary window components ───

console.log('[NSWindowExample] Registering secondary components');
AppRegistry.registerComponent('NotesWindow', () => NotesWindow);
AppRegistry.registerComponent('ColorWindow', () => ColorWindow);
AppRegistry.registerComponent('MiniWindow', () => MiniWindow);
console.log('[NSWindowExample] All components registered');

export default App;
