import { PieceData } from './types';

export const numToBoardNotation = (num: number) => {
  // 1 -> A, 2 -> B, 26 -> Z, 27 -> AA, 28 -> AB, etc.

  let notation = '';
  let remainder = num;

  while (remainder >= 0) {
    const digit = remainder % 26;
    notation = String.fromCharCode(65 + digit) + notation;
    remainder = Math.floor(remainder / 26) - 1;
  }
  return notation;
};

export const generateBoardNotationLetters = (size: number, isFlipped?: boolean) => {
  let letterList: string[] = [];

  // Generate letters for the notations
  // A-Z, AA-ZZ, AAA-ZZZ, etc.
  // Convert to base 26 pretty much

  for (let i = 0; i < size; i++) {
    if (isFlipped) {
      letterList.push(numToBoardNotation(size - i));
    } else {
      letterList.push(numToBoardNotation(i));
    }
  }

  return letterList;
};

export const convertFenCodeToBoardArray = (fenCode: string) => {
  // For example, fenCode = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
  // Should be split into ["r", "n", "b", "q", "k", "b", "n", "r", "..." and so on]
  // The numbers add x empty spaces to the array
  // The "/" should be ignored

  const fenCodeArray = fenCode.split('/');
  const boardArray: string[] = [];

  for (const fenCodeRow of fenCodeArray) {
    const fenCodeRowArray = fenCodeRow.split('');
    for (const fenCodePiece of fenCodeRowArray) {
      if (isNaN(Number(fenCodePiece))) {
        boardArray.push(fenCodePiece);
      } else {
        for (let i = 0; i < Number(fenCodePiece); i++) {
          boardArray.push('');
        }
      }
    }
  }

  return boardArray;
};

export const convertBoardToGNot = (width: number, height: number, pieces: PieceData[]) => {
  // Convert the pieces on a board into a GNot string, comma separated
  // For example, if the board is 8x8 a string could formatted like this:
  // r,n,b,q,k,b,n,r,p,p,p,p,p,p,p,p,32,P,P,P,P,P,P,P,P,R,N,B,Q,K,B,N,R
  // The numbers are the number of empty spaces

  // The pieces have x and y coordinates, but we need to convert them to a 1D array
  // and place them in the correct order, filled with empty spaces in between

  let boardArray = Array(width * height).fill('');

  Object.keys(pieces).forEach((pieceKey) => {
    const piece = pieces[pieceKey];
    const index = piece.y * width + piece.x;
    boardArray[index] = piece.code;
  });

  let gNotString = '';
  let emptySpaces = 0;

  for (const piece of boardArray) {
    if (piece === '') {
      emptySpaces++;
    } else {
      if (emptySpaces > 0) {
        gNotString += `${emptySpaces},`;
        emptySpaces = 0;
      }
      gNotString += `${piece},`;
    }
  }

  // Remove the last comma
  gNotString = gNotString.slice(0, -1);

  return gNotString;
};
