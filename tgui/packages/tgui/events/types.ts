import type { ExtractAtomValue } from 'jotai';
import type { BooleanLike } from 'tgui-core/react';

import type { sendAct } from './act';
import type { backendStateAtom } from './store';

export type WindowMode = 'light' | 'dark'; // |GOONSTATION-ADD|

type Client = {
  address: string;
  ckey: string;
  computer_id: string;
};

type IFace = {
  layout: string;
  name: string;
};

type TguiWindow = {
  fancy: BooleanLike;
  key: string;
  locked: BooleanLike;
  mode: WindowMode; // |GOONSTATION-ADD|
  scale: BooleanLike;
  size: [number, number];
};

type User = {
  name: string;
  observer: number;
};

export type Config = {
  cdn: string; // |GOONSTATION-ADD|
  client: Client;
  interface: IFace;
  refreshing: BooleanLike;
  /** |GOONSTATION-ADD| interface name -> secret id */
  secretInterfaces?: Record<string, string>;
  status: number;
  title: string;
  user: User;
  window: TguiWindow;
};

export type DebugState = {
  debugLayout: boolean;
  kitchenSink: boolean;
};

export type BackendState<TData> = ExtractAtomValue<typeof backendStateAtom> & {
  act: typeof sendAct;
  data: TData;
};
