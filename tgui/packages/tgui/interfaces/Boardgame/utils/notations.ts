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
  // i guess, I can't even count to 10, let alone 26

  for (let i = 0; i < size; i++) {
    if (isFlipped) {
      letterList.push(numToBoardNotation(size - i));
    } else {
      letterList.push(numToBoardNotation(i));
    }
  }

  return letterList;
};
