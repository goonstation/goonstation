import { useLocalState } from '../../../backend';
import { XYType, TileSizeType } from '.';

export const DEFAULT_STATES = {
  FLIP: false,
  ZOOM: 1,
  MOUSE_COORDS: { x: 0, y: 0 },
};

export const STATES = (context) => {
  return {
    // Board game
    flip: useLocalState<boolean>(context, 'flip', DEFAULT_STATES.FLIP),
    zoom: useLocalState<number>(context, 'zoom', DEFAULT_STATES.ZOOM),
    mouseCoords: useLocalState<XYType>(context, 'mouseCoords', DEFAULT_STATES.MOUSE_COORDS),
    palettesExpanded: useLocalState<PalleteExpandType>(context, 'palettesExpanded', {}),
    paletteLastElement: useLocalState<HTMLElement>(context, 'paletteLastElement', null),
    tileSize: useLocalState<TileSizeType>(context, 'tileSize', { width: 0, height: 0 }),
    helpModalOpen: useLocalState<boolean>(context, 'helpModalOpen', false),
  };
};

/**
 *
 * @param context
 * @returns an object with functions to update the state
 */
export const useStates = (context) => {
  const states = STATES(context);

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
      setPalettesExpanded({ ...states.palettesExpanded[0], [index]: !states.palettesExpanded[0][index] });
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
