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
    'The game of draughts was invented in ancient Egypt, and it has been played in various forms for over 5,000 years.',
    'The game was popular among the nobility in medieval Europe, and it was often used as a tool for teaching strategic thinking and problem-solving skills.',
    'In the 19th century, the game of draughts was used as a tool for studying artificial intelligence and computer programming.',
    'The longest draughts game on record lasted for 100 hours and was played in a world championship match in 1986.',
    "In some variations of the game, a piece that reaches the opponent's end of the board is promoted to a 'king', which can move in any direction and capture pieces diagonally.",
    'In the 19th century, the game of draughts was played on a board with 100 squares, and each player had 50 pieces.',
    "In some parts of the world, the game of draughts is known by different names, such as 'dame' in France, 'shashki' in Russia, and 'dama' in Spain.",
    "In the United States, the game of draughts is known as 'checkers', and it is a popular game played in schools, parks, and homes.",
    "The game of draughts has been featured in many books, movies, and TV shows, including the novel 'The Checkmate Man' by J.D. Salinger and the film 'The Draughtsman's Contract' by Peter Greenaway.",
  ],
};

export default kit;
