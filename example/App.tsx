import React, { useState, useEffect } from 'react';
import {
  AppRegistry,
  Dimensions,
  View,
  Text,
  StyleSheet,
  ScrollView,
  TextInput,
  TouchableOpacity,
} from 'react-native';
import NSWindowModule from 'react-native-nswindow';
import type {
  WindowMovePayload,
  WindowResizePayload,
  WindowOcclusionStatePayload,
} from 'react-native-nswindow';

console.log('[NSWindowExample] App.tsx loading...');
console.log('[NSWindowExample] NSWindowModule:', NSWindowModule);
console.log(
  '[NSWindowExample] NSWindowModule keys:',
  Object.getOwnPropertyNames(NSWindowModule)
);
console.log(
  '[NSWindowExample] Dimensions.get("screen"):',
  Dimensions.get('screen')
);

// ─── Styled Button ───

function Btn({ title, onPress }: { title: string; onPress: () => void }) {
  return (
    <TouchableOpacity style={styles.btn} onPress={onPress} activeOpacity={0.7}>
      <Text style={styles.btnText}>{title}</Text>
    </TouchableOpacity>
  );
}

// ─── Secondary window components ───

function NotesWindow() {
  console.log('[NotesWindow] Rendering');
  const [text, setText] = useState('');
  return (
    <View style={[styles.container, { backgroundColor: '#fff' }]}>
      <Text style={[styles.title, { color: '#000' }]}>📝 Notes</Text>
      <TextInput
        style={styles.textInput}
        multiline
        value={text}
        onChangeText={(v) => {
          console.log('[NotesWindow] onChangeText:', v.length, 'chars');
          setText(v);
        }}
        placeholder='Type notes here...'
        placeholderTextColor='#999'
      />
    </View>
  );
}

function ColorWindow({ color = '#ff6b6b' }: { color?: string }) {
  console.log('[ColorWindow] Rendering with color:', color);
  return (
    <View style={[styles.container, { backgroundColor: color }]}>
      <Text style={[styles.title, { color: '#fff' }]}>🎨 Color Window</Text>
      <Text style={[styles.subtitle, { color: '#fff' }]}>
        Background: {color}
      </Text>
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
      NSWindowModule.onWindowOcclusionStateChange(
        (p: WindowOcclusionStatePayload) => {
          console.log('[App] onWindowOcclusionStateChange:', p);
          appendLog(
            `occlusion: ${p.windowId.slice(0, 8)} visible=${p.isVisible}`
          );
        }
      ),
      NSWindowModule.onWindowBackingPropertiesChange((windowId: string) => {
        console.log('[App] onWindowBackingPropertiesChange:', windowId);
        appendLog(`backingChange: ${windowId.slice(0, 8)}`);
      }),
      NSWindowModule.onScreenInfoChange(() => {
        console.log('[App] onScreenInfoChange');
        appendLog('screenInfoChange');
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

  const openAutoSave = async () => {
    console.log('[App] openAutoSave called');
    try {
      const id = await NSWindowModule.addWindow({
        componentName: 'NotesWindow',
        windowName: 'autosave-test',
        initialProps: {},
        title: 'AutoSave Frame',
        width: 500,
        height: 350,
        autoSaveFrame: 'myAutoSaveWindow',
        hasShadow: true,
      });
      console.log('[App] opened autosave window:', id);
      appendLog(`opened autosave: ${id.slice(0, 8)}`);
      refreshWindows();
    } catch (e: any) {
      console.error('[App] openAutoSave error:', e);
      appendLog(`ERROR openAutoSave: ${e.message}`);
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
    <View style={styles.outerContainer}>
      <ScrollView
        style={styles.scroll}
        contentContainerStyle={styles.scrollContent}
      >
        <Text style={styles.header}>NSWindow Example</Text>

        <Text style={styles.section}>Create Windows</Text>
        <View style={styles.row}>
          <Btn
            title='📝 Notes'
            onPress={() => {
              console.log('[App] Button press: Notes');
              openNotes();
            }}
          />
          <Btn
            title='🎨 Color'
            onPress={() => {
              console.log('[App] Button press: Color');
              openColor();
            }}
          />
          <Btn
            title='🔲 Mini (On Top)'
            onPress={() => {
              console.log('[App] Button press: Mini');
              openMini();
            }}
          />
          <Btn
            title='👻 Hidden'
            onPress={() => {
              console.log('[App] Button press: Hidden');
              openHidden();
            }}
          />
          <Btn
            title='💾 AutoSave'
            onPress={() => {
              console.log('[App] Button press: AutoSave');
              openAutoSave();
            }}
          />
        </View>

        <Text style={styles.section}>
          Window Actions{' '}
          {firstId ? `(on ${firstId.slice(0, 8)})` : '(none open)'}
        </Text>
        <View style={styles.row}>
          <Btn
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
          <Btn
            title='Close'
            onPress={() =>
              safeCall('closeWindow', () => NSWindowModule.closeWindow(firstId))
            }
          />
          <Btn
            title='Focus'
            onPress={() =>
              safeCall('focusWindow', () => NSWindowModule.focusWindow(firstId))
            }
          />
          <Btn
            title='Hide'
            onPress={() =>
              safeCall('hideWindow', () => NSWindowModule.hideWindow(firstId))
            }
          />
          <Btn
            title='Show'
            onPress={() =>
              safeCall('showWindow', () => NSWindowModule.showWindow(firstId))
            }
          />
          <Btn
            title='Minimize'
            onPress={() =>
              safeCall('minimizeWindow', () =>
                NSWindowModule.minimizeWindow(firstId)
              )
            }
          />
          <Btn
            title='Deminimize'
            onPress={() =>
              safeCall('deminimizeWindow', () =>
                NSWindowModule.deminimizeWindow(firstId)
              )
            }
          />
          <Btn
            title='FullScreen On'
            onPress={() =>
              safeCall('setFullScreen(true)', () =>
                NSWindowModule.setFullScreen(firstId, true)
              )
            }
          />
          <Btn
            title='FullScreen Off'
            onPress={() =>
              safeCall('setFullScreen(false)', () =>
                NSWindowModule.setFullScreen(firstId, false)
              )
            }
          />
          <Btn
            title='Bring Front'
            onPress={() =>
              safeCall('bringToFront', () =>
                NSWindowModule.bringToFront(firstId)
              )
            }
          />
          <Btn
            title='Send Back'
            onPress={() =>
              safeCall('sendToBack', () => NSWindowModule.sendToBack(firstId))
            }
          />
          <Btn
            title='Get State'
            onPress={async () => {
              if (!firstId) {
                return;
              }
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
          <Btn
            title='Screen Info'
            onPress={async () => {
              try {
                const info = await NSWindowModule.getScreenInfo();
                console.log('[App] getScreenInfo:', info);
                appendLog(`screenInfo: ${JSON.stringify(info)}`);
              } catch (e: any) {
                console.error('[App] getScreenInfo error:', e);
                appendLog(`ERROR getScreenInfo: ${e.message}`);
              }
            }}
          />
        </View>

        <Text style={styles.section}>Modify Last Window</Text>
        <View style={styles.row}>
          <Btn
            title='Resize 600x400'
            onPress={() => {
              const payload = { width: 600, height: 400 };
              console.log('[App] modifyWindow:', firstId, payload);
              safeCall('modifyWindow(size)', () =>
                NSWindowModule.modifyWindow(firstId, payload)
              );
            }}
          />
          <Btn
            title='Move (100,100)'
            onPress={() => {
              const payload = { x: 100, y: 100 };
              console.log('[App] modifyWindow:', firstId, payload);
              safeCall('modifyWindow(pos)', () =>
                NSWindowModule.modifyWindow(firstId, payload)
              );
            }}
          />
          <Btn
            title='Center'
            onPress={() => {
              safeCall('modifyWindow(center)', () =>
                NSWindowModule.modifyWindow(firstId, { center: true })
              );
            }}
          />
          <Btn
            title='Title: Modified'
            onPress={() => {
              safeCall('modifyWindow(title)', () =>
                NSWindowModule.modifyWindow(firstId, { title: 'Modified!' })
              );
            }}
          />
          <Btn
            title='Lock Resize'
            onPress={() => {
              safeCall('modifyWindow(noResize)', () =>
                NSWindowModule.modifyWindow(firstId, { resizable: false })
              );
            }}
          />
          <Btn
            title='Unlock Resize'
            onPress={() => {
              safeCall('modifyWindow(resize)', () =>
                NSWindowModule.modifyWindow(firstId, { resizable: true })
              );
            }}
          />
          <Btn
            title='Prevent Close'
            onPress={() => {
              safeCall('modifyWindow(preventClose)', () =>
                NSWindowModule.modifyWindow(firstId, { stopShouldClose: true })
              );
            }}
          />
          <Btn
            title='Allow Close'
            onPress={() => {
              safeCall('modifyWindow(allowClose)', () =>
                NSWindowModule.modifyWindow(firstId, { stopShouldClose: false })
              );
            }}
          />
          <Btn
            title='TitleBar Hidden'
            onPress={() => {
              safeCall('modifyWindow(titleBarHidden)', () =>
                NSWindowModule.modifyWindow(firstId, {
                  titleBarStyle: 'hidden',
                })
              );
            }}
          />
          <Btn
            title='TitleBar Default'
            onPress={() => {
              safeCall('modifyWindow(titleBarDefault)', () =>
                NSWindowModule.modifyWindow(firstId, {
                  titleBarStyle: 'default',
                })
              );
            }}
          />
          <Btn
            title='Vibrancy Sidebar'
            onPress={() => {
              safeCall('modifyWindow(vibrancySidebar)', () =>
                NSWindowModule.modifyWindow(firstId, { vibrancy: 'sidebar' })
              );
            }}
          />
          <Btn
            title='Vibrancy None'
            onPress={() => {
              safeCall('modifyWindow(vibrancyNone)', () =>
                NSWindowModule.modifyWindow(firstId, { vibrancy: 'none' })
              );
            }}
          />
          <Btn
            title='BG Red'
            onPress={() => {
              safeCall('modifyWindow(bgRed)', () =>
                NSWindowModule.modifyWindow(firstId, {
                  backgroundColor: '#ff0000',
                })
              );
            }}
          />
          <Btn
            title='BG Blue'
            onPress={() => {
              safeCall('modifyWindow(bgBlue)', () =>
                NSWindowModule.modifyWindow(firstId, {
                  backgroundColor: '#0000ff',
                })
              );
            }}
          />
          <Btn
            title='Shadow Off'
            onPress={() => {
              safeCall('modifyWindow(noShadow)', () =>
                NSWindowModule.modifyWindow(firstId, { hasShadow: false })
              );
            }}
          />
          <Btn
            title='Shadow On'
            onPress={() => {
              safeCall('modifyWindow(shadow)', () =>
                NSWindowModule.modifyWindow(firstId, { hasShadow: true })
              );
            }}
          />
          <Btn
            title='No Minimize'
            onPress={() => {
              safeCall('modifyWindow(noMin)', () =>
                NSWindowModule.modifyWindow(firstId, { minimizable: false })
              );
            }}
          />
          <Btn
            title='Minimizable'
            onPress={() => {
              safeCall('modifyWindow(min)', () =>
                NSWindowModule.modifyWindow(firstId, { minimizable: true })
              );
            }}
          />
          <Btn
            title='No Close Btn'
            onPress={() => {
              safeCall('modifyWindow(noCloseBtn)', () =>
                NSWindowModule.modifyWindow(firstId, { closable: false })
              );
            }}
          />
          <Btn
            title='Closable'
            onPress={() => {
              safeCall('modifyWindow(closeBtn)', () =>
                NSWindowModule.modifyWindow(firstId, { closable: true })
              );
            }}
          />
          <Btn
            title='No Zoom'
            onPress={() => {
              safeCall('modifyWindow(noZoom)', () =>
                NSWindowModule.modifyWindow(firstId, { zoomable: false })
              );
            }}
          />
          <Btn
            title='Zoomable'
            onPress={() => {
              safeCall('modifyWindow(zoom)', () =>
                NSWindowModule.modifyWindow(firstId, { zoomable: true })
              );
            }}
          />
          <Btn
            title='Lock Move'
            onPress={() => {
              safeCall('modifyWindow(noMove)', () =>
                NSWindowModule.modifyWindow(firstId, { movable: false })
              );
            }}
          />
          <Btn
            title='Unlock Move'
            onPress={() => {
              safeCall('modifyWindow(move)', () =>
                NSWindowModule.modifyWindow(firstId, { movable: true })
              );
            }}
          />
          <Btn
            title='Always On Top'
            onPress={() => {
              safeCall('modifyWindow(onTop)', () =>
                NSWindowModule.modifyWindow(firstId, { alwaysOnTop: true })
              );
            }}
          />
          <Btn
            title='Normal Level'
            onPress={() => {
              safeCall('modifyWindow(normalLevel)', () =>
                NSWindowModule.modifyWindow(firstId, {
                  alwaysOnTop: false,
                  level: 'normal',
                })
              );
            }}
          />
        </View>
      </ScrollView>

      <Text style={styles.logHeader}>Event Log</Text>
      <ScrollView
        style={styles.logBox}
        contentContainerStyle={styles.logContent}
      >
        {log.map((entry, i) => (
          <Text key={i} style={styles.logEntry}>
            {entry}
          </Text>
        ))}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  outerContainer: { flex: 1, backgroundColor: '#f5f5f5' },
  scroll: { flexShrink: 1 },
  scrollContent: { padding: 20 },
  header: { fontSize: 24, fontWeight: 'bold', marginBottom: 16, color: '#000' },
  section: {
    fontSize: 16,
    fontWeight: '600',
    marginTop: 16,
    marginBottom: 8,
    color: '#000',
  },
  row: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  btn: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    backgroundColor: '#007AFF',
    borderRadius: 6,
  },
  btnText: { color: '#fff', fontSize: 13, fontWeight: '500' },
  container: {
    flex: 1,
    padding: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: { fontSize: 20, fontWeight: 'bold', color: '#000' },
  subtitle: { fontSize: 14, marginTop: 8, opacity: 0.7, color: '#000' },
  textInput: {
    flex: 1,
    width: '100%',
    marginTop: 12,
    padding: 10,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 6,
    fontSize: 14,
    color: '#000',
    backgroundColor: '#fff',
    textAlignVertical: 'top',
  },
  logBox: { flex: 1, padding: 10, backgroundColor: '#1e1e1e' },
  logHeader: {
    fontSize: 16,
    fontWeight: '600',
    marginTop: 8,
    marginBottom: 8,
    marginHorizontal: 20,
    color: '#000',
  },
  logContent: { paddingBottom: 10 },
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
