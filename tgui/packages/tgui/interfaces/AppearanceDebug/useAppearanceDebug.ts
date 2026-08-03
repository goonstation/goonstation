import {
  createContext,
  type Dispatch,
  type SetStateAction,
  useContext,
} from 'react';

import type { AppearanceMap } from './types';

type AppearanceDebugContextType = {
  act: (action: string, params?: object) => void;
  planeToText: Record<string, number>;
  layerToText: Record<string, number>;
  flagsToText: Record<string, number>;
  visToText: Record<string, number>;
  blendToText: Record<string, string>;
  mapRefHover: string;
  mapRefSelected: string;
  appsProcessed: AppearanceMap;
  zoomToX: number | undefined;
  setZoomToX: Dispatch<SetStateAction<number | undefined>>;
  zoomToY: number | undefined;
  setZoomToY: Dispatch<SetStateAction<number | undefined>>;
};

export const AppearanceDebugContext = createContext(
  {} as AppearanceDebugContextType,
);

export function useAppearanceDebugContext() {
  return useContext(AppearanceDebugContext);
}
