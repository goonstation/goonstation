import { useLocalState } from '../../../backend';
import { PalleteExpandType, TileSizeType, XYType } from '.';

export const DEFAULT_STATES = {
  // TODO: add more default states here
  FLIP: false,
  ZOOM: 1,
  MOUSE_COORDS: { x: 0, y: 0 },
};

export const STATES = () => {
  return {
    // TODO: add more states here
    flip: useLocalState<boolean>('flip', DEFAULT_STATES.FLIP),
    zoom: useLocalState<number>('zoom', DEFAULT_STATES.ZOOM),
    mouseCoords: useLocalState<XYType>(
      'mouseCoords',
      DEFAULT_STATES.MOUSE_COORDS,
    ),
    palettesExpanded: useLocalState<PalleteExpandType>('palettesExpanded', {}),
    paletteLastElement: useLocalState<HTMLElement | null>(
      'paletteLastElement',
      null,
    ),
    tileSize: useLocalState<TileSizeType>('tileSize', { width: 0, height: 0 }),
    helpModalOpen: useLocalState<boolean>('helpModalOpen', false),
  };
};

/**
 *
 * @param context
 * @returns an object with functions to update the state
 */
export const useStates = () => {
  const states = STATES();

  return {
    paletteLastElementSet: (element: HTMLElement) => {
      const [, setPaletteLastElement] = states.paletteLastElement;
      setPaletteLastElement(element);
    },
    paletteLastElement: states.paletteLastElement[0],
    mouseCoordsSet: (coords: XYType) => {
      const [, setMouseCoords] = states.mouseCoords;
      setMouseCoords({
        x: coords.x,
        y: coords.y,
      });
    },
    mouseCoords: states.mouseCoords[0],
    // Misc
    toggleFlip: () => {
      const [flip, setFlip] = states.flip;
      setFlip(!flip);
    },
    isFlipped: states.flip[0],
    // Help Modal
    helpModalClose: () => {
      const [, setHelpModalOpen] = states.helpModalOpen;
      setHelpModalOpen(false);
    },
    helpModalOpen: () => {
      const [, setHelpModalOpen] = states.helpModalOpen;
      setHelpModalOpen(true);
    },
    isHelpModalOpen: states.helpModalOpen[0],

    // Palettes
    expandPalette: (index: number) => {
      const [, setPalettesExpanded] = states.palettesExpanded;
      setPalettesExpanded({ ...states.palettesExpanded[0], [index]: true });
    },

    togglePalette: (index: number) => {
      const [, setPalettesExpanded] = states.palettesExpanded;
      setPalettesExpanded({
        ...states.palettesExpanded[0],
        [index]: !states.palettesExpanded[0][index],
      });
    },

    isExpanded: (index: number) => {
      return !!states.palettesExpanded[0][index];
    },

    // Board
    setTileSizeType: (size: TileSizeType) => {
      const [, setTileSizeType] = states.tileSize;
      setTileSizeType(size);
    },
    tileSize: states.tileSize[0],
  };
};
