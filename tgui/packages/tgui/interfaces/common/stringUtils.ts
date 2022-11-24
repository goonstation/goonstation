import { randInt } from './mathUtils';

export const pluralize = (word: string, n: number) => (n !== 1 ? word + 's' : word);

export const capitalize = (word: string) => word.replace(/(^\w{1})|(\s+\w{1})/g, letter => letter.toUpperCase());

const glitches = ['$', '{', ']', '%', '^', '?', '>', '¬', 'π', ';', 'и', 'ѫ', '/', '#', '~'];
export const glitch = (text: string, amount: number) => {
  const chars = text.split('');
  for (let i = 0; i < amount; i++) {
    const charIndex = randInt(0, chars.length ? chars.length - 1 : 0);
    chars[charIndex] = glitches[randInt(0, glitches.length - 1)];
  }
  return chars.join('');
};
