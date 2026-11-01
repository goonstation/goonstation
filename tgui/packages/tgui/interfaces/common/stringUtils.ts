import { randInt } from './mathUtils';

export const capitalize = (word: string) =>
  word.replace(/(^\w{1})|(\s+\w{1})/g, (letter) => letter.toUpperCase());

export const spaceUnderscores = (word: string) =>
  word.replace(/[_]/g, (letter) => ' ');

const glitches = [
  '$',
  '{',
  ']',
  '%',
  '^',
  '?',
  '>',
  '¬',
  'π',
  ';',
  'и',
  'ѫ',
  '/',
  '#',
  '~',
];
export const glitch = (text: string, amount: number) => {
  const chars = text.split('');
  for (let i = 0; i < amount; i++) {
    const charIndex = randInt(0, chars.length ? chars.length - 1 : 0);
    chars[charIndex] = glitches[randInt(0, glitches.length - 1)];
  }
  return chars.join('');
};

export const asCreditsString = (amount: number) => `${amount}⪽`;
