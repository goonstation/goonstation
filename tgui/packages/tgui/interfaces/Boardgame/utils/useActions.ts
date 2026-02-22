import { PieceDataType, UserDataType } from '.';

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
    pieceRemove: (piece: number | PieceDataType | string) => {
      act('pieceRemove', { piece });
    },
    pieceRemoveHeld: (ckey: string | UserDataType) => {
      act('pieceRemoveHeld', {
        ckey,
      });
    },
    pieceSelect: (
      ckey: string | UserDataType,
      piece: string | PieceDataType,
    ) => {
      act('pieceSelect', { ckey, piece });
    },
    pieceDeselect: (ckey: string | UserDataType) => {
      act('pieceDeselect', {
        ckey,
      });
    },
    piecePlace: (ckey: string | UserDataType, x: number, y: number) => {
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
    paletteClear: (ckey: string | UserDataType) => {
      act('paletteClear', {
        ckey,
      });
    },
    boardClear: () => {
      let gnot = '';
      act('applyGNot', { gnot: gnot });
    },
  };

  return actions;
};
