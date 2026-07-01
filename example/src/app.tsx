import React, { useState, useEffect } from 'react';
import {
  AppRegistry,
  Dimensions,
  View,
  Text,
  StyleSheet,
  ScrollView,
} from 'react-native';
import NSWindowModule from 'react-native-nswindow';
import type {
  WindowMovePayload,
  WindowResizePayload,
  WindowOcclusionStatePayload,
} from 'react-native-nswindow';
import NotesWindow from './notes_window';
import ColorWindow from './color_window';
import MiniWindow from './mini_window';
import TextButton from './components/text_button';
import Select from './components/select';

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

// ─── Main window ───

function App() {
  console.log('[App] Rendering main window');
  const [log, setLog] = useState<string[]>([]);
  const [windows, setWindows] = useState<string[]>([]);
  const [actionWindowId, setActionWindowId] = useState<string | undefined>();
  const [modifyWindowId, setModifyWindowId] = useState<string | undefined>();

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

  const safeCall = async (
    name: string,
    targetId: string | undefined,
    fn: () => Promise<any>
  ) => {
    console.log(`[App] safeCall: ${name}, windowId:`, targetId);
    try {
      const result = await fn();
      console.log(`[App] ${name} result:`, result);
      appendLog(`${name} (${targetId?.slice(0, 8) ?? 'none'}): success`);
      return result;
    } catch (e: any) {
      console.error(`[App] ${name} error:`, e);
      appendLog(
        `ERROR ${name} (${targetId?.slice(0, 8) ?? 'none'}): ${e.message}`
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
          <TextButton
            title='📝 Notes'
            onPress={() => {
              console.log('[App] Button press: Notes');
              openNotes();
            }}
          />
          <TextButton
            title='🎨 Color'
            onPress={() => {
              console.log('[App] Button press: Color');
              openColor();
            }}
          />
          <TextButton
            title='🔲 Mini (On Top)'
            onPress={() => {
              console.log('[App] Button press: Mini');
              openMini();
            }}
          />
          <TextButton
            title='👻 Hidden'
            onPress={() => {
              console.log('[App] Button press: Hidden');
              openHidden();
            }}
          />
          <TextButton
            title='💾 AutoSave'
            onPress={() => {
              console.log('[App] Button press: AutoSave');
              openAutoSave();
            }}
          />
        </View>

        <Text style={styles.section}>Window Actions</Text>
        <Select
          options={windows}
          selectedValue={actionWindowId}
          onSelect={setActionWindowId}
          placeholder='— select window —'
        />
        <View style={styles.row}>
          <TextButton
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
          <TextButton
            title='Close'
            onPress={() =>
              safeCall('closeWindow', actionWindowId, () =>
                NSWindowModule.closeWindow(actionWindowId!)
              )
            }
          />
          <TextButton
            title='Focus'
            onPress={() =>
              safeCall('focusWindow', actionWindowId, () =>
                NSWindowModule.focusWindow(actionWindowId!)
              )
            }
          />
          <TextButton
            title='Hide'
            onPress={() =>
              safeCall('hideWindow', actionWindowId, () =>
                NSWindowModule.hideWindow(actionWindowId!)
              )
            }
          />
          <TextButton
            title='Show'
            onPress={() =>
              safeCall('showWindow', actionWindowId, () =>
                NSWindowModule.showWindow(actionWindowId!)
              )
            }
          />
          <TextButton
            title='Minimize'
            onPress={() =>
              safeCall('minimizeWindow', actionWindowId, () =>
                NSWindowModule.minimizeWindow(actionWindowId!)
              )
            }
          />
          <TextButton
            title='Deminimize'
            onPress={() =>
              safeCall('deminimizeWindow', actionWindowId, () =>
                NSWindowModule.deminimizeWindow(actionWindowId!)
              )
            }
          />
          <TextButton
            title='FullScreen On'
            onPress={() =>
              safeCall('setFullScreen(true)', actionWindowId, () =>
                NSWindowModule.setFullScreen(actionWindowId!, true)
              )
            }
          />
          <TextButton
            title='FullScreen Off'
            onPress={() =>
              safeCall('setFullScreen(false)', actionWindowId, () =>
                NSWindowModule.setFullScreen(actionWindowId!, false)
              )
            }
          />
          <TextButton
            title='Bring Front'
            onPress={() =>
              safeCall('bringToFront', actionWindowId, () =>
                NSWindowModule.bringToFront(actionWindowId!)
              )
            }
          />
          <TextButton
            title='Send Back'
            onPress={() =>
              safeCall('sendToBack', actionWindowId, () =>
                NSWindowModule.sendToBack(actionWindowId!)
              )
            }
          />
          <TextButton
            title='Get State'
            onPress={async () => {
              if (!actionWindowId) {
                return;
              }
              try {
                const state =
                  await NSWindowModule.getWindowState(actionWindowId);
                console.log('[App] getWindowState:', state);
                appendLog(`getState: ${JSON.stringify(state)}`);
              } catch (e: any) {
                console.error('[App] getWindowState error:', e);
                appendLog(`ERROR getWindowState: ${e.message}`);
              }
            }}
          />
          <TextButton
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

        <Text style={styles.section}>Modify Window</Text>
        <Select
          options={windows}
          selectedValue={modifyWindowId}
          onSelect={setModifyWindowId}
          placeholder='— select window —'
        />
        <View style={styles.row}>
          <TextButton
            title='Resize 600x400'
            onPress={() => {
              const payload = { width: 600, height: 400 };
              console.log('[App] modifyWindow:', modifyWindowId, payload);
              safeCall('modifyWindow(size)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, payload)
              );
            }}
          />
          <TextButton
            title='Move (100,100)'
            onPress={() => {
              const payload = { x: 100, y: 100 };
              console.log('[App] modifyWindow:', modifyWindowId, payload);
              safeCall('modifyWindow(pos)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, payload)
              );
            }}
          />
          <TextButton
            title='Center'
            onPress={() => {
              safeCall('modifyWindow(center)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, { center: true })
              );
            }}
          />
          <TextButton
            title='Title: Modified'
            onPress={() => {
              safeCall('modifyWindow(title)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  title: 'Modified!',
                })
              );
            }}
          />
          <TextButton
            title='Lock Resize'
            onPress={() => {
              safeCall('modifyWindow(noResize)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  resizable: false,
                })
              );
            }}
          />
          <TextButton
            title='Unlock Resize'
            onPress={() => {
              safeCall('modifyWindow(resize)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  resizable: true,
                })
              );
            }}
          />
          <TextButton
            title='Prevent Close'
            onPress={() => {
              safeCall('modifyWindow(preventClose)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  stopShouldClose: true,
                })
              );
            }}
          />
          <TextButton
            title='Allow Close'
            onPress={() => {
              safeCall('modifyWindow(allowClose)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  stopShouldClose: false,
                })
              );
            }}
          />
          <TextButton
            title='TitleBar Hidden'
            onPress={() => {
              safeCall('modifyWindow(titleBarHidden)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  titleBarStyle: 'hidden',
                })
              );
            }}
          />
          <TextButton
            title='TitleBar Default'
            onPress={() => {
              safeCall('modifyWindow(titleBarDefault)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  titleBarStyle: 'default',
                })
              );
            }}
          />
          <TextButton
            title='Vibrancy Sidebar'
            onPress={() => {
              safeCall('modifyWindow(vibrancySidebar)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  vibrancy: 'sidebar',
                })
              );
            }}
          />
          <TextButton
            title='Vibrancy None'
            onPress={() => {
              safeCall('modifyWindow(vibrancyNone)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  vibrancy: 'none',
                })
              );
            }}
          />
          <TextButton
            title='BG Red'
            onPress={() => {
              safeCall('modifyWindow(bgRed)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  backgroundColor: '#ff0000',
                })
              );
            }}
          />
          <TextButton
            title='BG Blue'
            onPress={() => {
              safeCall('modifyWindow(bgBlue)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  backgroundColor: '#0000ff',
                })
              );
            }}
          />
          <TextButton
            title='Shadow Off'
            onPress={() => {
              safeCall('modifyWindow(noShadow)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  hasShadow: false,
                })
              );
            }}
          />
          <TextButton
            title='Shadow On'
            onPress={() => {
              safeCall('modifyWindow(shadow)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  hasShadow: true,
                })
              );
            }}
          />
          <TextButton
            title='No Minimize'
            onPress={() => {
              safeCall('modifyWindow(noMin)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  minimizable: false,
                })
              );
            }}
          />
          <TextButton
            title='Minimizable'
            onPress={() => {
              safeCall('modifyWindow(min)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  minimizable: true,
                })
              );
            }}
          />
          <TextButton
            title='No Close Btn'
            onPress={() => {
              safeCall('modifyWindow(noCloseBtn)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  closable: false,
                })
              );
            }}
          />
          <TextButton
            title='Closable'
            onPress={() => {
              safeCall('modifyWindow(closeBtn)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, { closable: true })
              );
            }}
          />
          <TextButton
            title='No Zoom'
            onPress={() => {
              safeCall('modifyWindow(noZoom)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  zoomable: false,
                })
              );
            }}
          />
          <TextButton
            title='Zoomable'
            onPress={() => {
              safeCall('modifyWindow(zoom)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, { zoomable: true })
              );
            }}
          />
          <TextButton
            title='Lock Move'
            onPress={() => {
              safeCall('modifyWindow(noMove)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, { movable: false })
              );
            }}
          />
          <TextButton
            title='Unlock Move'
            onPress={() => {
              safeCall('modifyWindow(move)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, { movable: true })
              );
            }}
          />
          <TextButton
            title='Always On Top'
            onPress={() => {
              safeCall('modifyWindow(onTop)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
                  alwaysOnTop: true,
                })
              );
            }}
          />
          <TextButton
            title='Normal Level'
            onPress={() => {
              safeCall('modifyWindow(normalLevel)', modifyWindowId, () =>
                NSWindowModule.modifyWindow(modifyWindowId!, {
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
