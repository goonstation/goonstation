import { GameKit } from '..';
import pieces from './pieces';
import presets from './presets';

// Export as gamekit module, use type GameKit

export const kit: GameKit = {
  pieces,
  presets,
  palettes: [
    {
      name: 'Draughts',
      pieces,
    },
  ],
  facts: [
    'Draughts is a game of strategy and skill.',
    'Only one piece can be moved at a time.',
    'Draughts was invented in the 12th century.',
    'The game is also known as checkers.',
    'For every 100 draughts games played, 1 is a draw.',
    'The longest draughts game ever played lasted 10 days.',
    'The most common draughts opening is the Ruy Lopez.',
    'To play draughts, you need 32 pieces.',
    'After the first 20 moves, there are 400 possible moves.',
  ],
};

export default kit;
