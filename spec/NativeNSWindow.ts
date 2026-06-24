import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';
import type { EventEmitter } from 'react-native/Libraries/Types/CodegenTypes';

export type TitleBarStyle =
  | 'default'
  | 'hidden'
  | 'hiddenInset'
  | 'transparent';

export type WindowLevel =
  | 'normal'
  | 'floating'
  | 'modalPanel'
  | 'mainMenu'
  | 'statusBar'
  | 'screenSaver';

export interface WindowProps {
  componentName: string;
  windowName: string;
  initialProps?: Record<string, unknown>;

  x?: number;
  y?: number;
  width?: number;
  height?: number;
  minWidth?: number;
  minHeight?: number;
  maxWidth?: number;
  maxHeight?: number;
  center?: boolean;

  title?: string;
  titleBarStyle?: TitleBarStyle;
  vibrancy?:
    | 'none'
    | 'sidebar'
    | 'menu'
    | 'popover'
    | 'fullScreenUI'
    | 'underWindowBackground'
    | 'hudWindow';
  backgroundColor?: string;
  transparent?: boolean;
  hasShadow?: boolean;

  resizable?: boolean;
  movable?: boolean;
  minimizable?: boolean;
  closable?: boolean;
  zoomable?: boolean;
  alwaysOnTop?: boolean;
  level?: WindowLevel;

  show?: boolean;
  focusOnCreate?: boolean;
  autoSaveFrame?: string;
}

export type ModifyableWindowProps = Partial<
  Omit<WindowProps, 'componentName' | 'windowName' | 'initialProps'>
>;

export interface WindowState {
  windowId: string;
  windowName: string;
  x: number;
  y: number;
  width: number;
  height: number;
  isKeyWindow: boolean;
  isMinimized: boolean;
  isFullScreen: boolean;
  isVisible: boolean;
}

export type WindowId = string;

export interface WindowMovePayload extends WindowIdPayload {
  windowId: string;
  x: number;
  y: number;
}
export interface WindowResizePayload extends WindowIdPayload {
  windowId: string;
  width: number;
  height: number;
}

export interface Spec extends TurboModule {
  addWindow(props: WindowProps): Promise<string>;
  closeWindow(windowId: string): Promise<void>;
  modifyWindow(windowId: string, props: ModifyableWindowProps): Promise<void>;

  listWindows(): Promise<string[]>;
  getWindowState(windowId: string): Promise<WindowState>;

  focusWindow(windowId: string): Promise<void>;
  hideWindow(windowId: string): Promise<void>;
  showWindow(windowId: string): Promise<void>;

  minimizeWindow(windowId: string): Promise<void>;
  deminimizeWindow(windowId: string): Promise<void>;
  setFullScreen(windowId: string, fullscreen: boolean): Promise<void>;

  bringToFront(windowId: string): Promise<void>;
  sendToBack(windowId: string): Promise<void>;

  acknowledgeClose(windowId: string, shouldClose: boolean): void;
  registerWillCloseHandler(windowId: string): void;
  unregisterWillCloseHandler(windowId: string): void;

  readonly onWindowClose: EventEmitter<WindowId>;
  readonly onWindowWillClose: EventEmitter<WindowId>;
  readonly onWindowMove: EventEmitter<WindowMovePayload>;
  readonly onWindowResize: EventEmitter<WindowResizePayload>;
  readonly onWindowFocus: EventEmitter<WindowId>;
  readonly onWindowBlur: EventEmitter<WindowId>;
  readonly onWindowMinimize: EventEmitter<WindowId>;
  readonly onWindowDeminimize: EventEmitter<WindowId>;
  readonly onWindowEnterFullScreen: EventEmitter<WindowId>;
  readonly onWindowExitFullScreen: EventEmitter<WindowId>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('NSWindowModule');
