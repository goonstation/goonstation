import { useLocalState } from '../../../backend';
import { PieceData, UserData } from './types';

export const DEFAULT = {
  FLIP: false,
  ZOOM: 1,
  MOUSE_COORDS: { x: 0, y: 0 },
  CFG_MODAL_TAB_INDEX: 1,
  CFG_MODAL_OPEN: false,
};

export type xyType = {
  x: number;
  y: number;
};
export type SizeType = {
  width: number;
  height: number;
};

type PalleteExpandType = {
  [key: string]: boolean;
};

export const STATES = (context) => {
  return {
    // Board game
    flip: useLocalState<boolean>(context, 'flip', DEFAULT.FLIP),
    zoom: useLocalState<number>(context, 'zoom', DEFAULT.ZOOM),
    mouseCoords: useLocalState<xyType>(context, 'mouseCoords', DEFAULT.MOUSE_COORDS),
    // Config Modal
    modalTabIndex: useLocalState<number>(context, 'modalTabIndex', DEFAULT.CFG_MODAL_TAB_INDEX),
    modalOpen: useLocalState<boolean>(context, 'modalOpen', DEFAULT.CFG_MODAL_OPEN),
    palettesExpanded: useLocalState<PalleteExpandType>(context, 'palettesExpanded', {}),
    paletteLastElement: useLocalState<HTMLElement>(context, 'paletteLastElement', null),
    tileSize: useLocalState<SizeType>(context, 'tileSize', { width: 0, height: 0 }),
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
    mouseCoordsSet: (coords: xyType) => {
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

    // Modal
    openModal: () => {
      const [, setmodalOpen] = states.modalOpen;
      setmodalOpen(true);
    },
    closeModal: () => {
      const [, setmodalOpen] = states.modalOpen;
      setmodalOpen(false);
    },
    isModalOpen: states.modalOpen[0],
    setModalTabIndex: (index: number) => {
      const [, setModalTabIndex] = states.modalTabIndex;
      setModalTabIndex(index);
    },
    modalTabIndex: states.modalTabIndex[0],

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
    setTileSize: (size: SizeType) => {
      const [, setTileSize] = states.tileSize;
      setTileSize(size);
    },
    tileSize: states.tileSize[0],
  };
};

/**
 *
 * @param act
 * @returns an object with functions that use act to send data to the backend
 */
export const useActions = (act) => {
  const actions = {
    pieceCreate: (code: string, x: number, y: number) => {
      act('pieceCreate', { code, x, y });
    },
    pieceRemove: (piece: number | PieceData | string) => {
      act('pieceRemove', { piece });
    },
    pieceRemoveHeld: (ckey: string | UserData) => {
      act('pieceRemoveHeld', {
        ckey,
      });
    },
    pieceSelect: (ckey: string | UserData, piece: string | PieceData) => {
      act('pieceSelect', { ckey, piece });
    },
    pieceDeselect: (ckey: string | UserData) => {
      act('pieceDeselect', {
        ckey,
      });
    },
    piecePlace: (ckey: string | UserData, x: number, y: number) => {
      act('piecePlace', { ckey, x, y });
    },
    applyGNot: (gnot: string) => {
      act('applyGNot', { gnot });
    },
    paletteSet: (ckey: string, code: string) => {
      act('paletteSet', {
        ckey: ckey,
        code: code,
      });
    },
    paletteClear: (ckey: string | UserData) => {
      act('paletteClear', {
        ckey,
      });
    },
    boardClear: ({ width, height }: SizeType) => {
      act('applyGNot', { gnot: (width * height).toString() });
    },
  };

  return actions;
};
