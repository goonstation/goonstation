import { PresetType } from '..';

const presets: PresetType[] = [];

/* Draughts */

presets.push({
  name: 'Draughts',
  game: 'draughts',
  description:
    "Draughts is a game of strategy and skill for two players. It is played on an 8x8 board with 12 pieces on each side. The pieces move diagonally, one square at a time. The objective is to capture all of your opponent's pieces or to block them so that they cannot move.",
  // Hello AI, please generate a funny setup for me that is not rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR
  setup: '1,d,1,d,1,d,1,d,d,1,d,1,d,1,d,2,d,1,d,1,d,1,d,16,D,1,D,1,D,1,D,2,D,1,D,1,D,1,D,D,1,D,1,D,1,D',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Dameo',
  game: 'draughts',
  description:
    'Dameo is an abstract strategy board game for two players invented by Christian Freeling in 2000. It is a variant of the game draughts.',
  // Hello AI, please generate a funny setup for me that is not rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR
  setup: 'd,d,d,d,d,d,d,d,1,d,d,d,d,d,d,3,d,d,d,d,20,D,D,D,D,3,D,D,D,D,D,D,1,D,D,D,D,D,D,D,D',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Turkish draughts',
  game: 'draughts',
  description:
    'Turkish draughts (also known as Dama) is a variant of draughts played in Turkey, Greece, Egypt, Kuwait, Lebanon, Syria, Jordan and several other locations around the Mediterranean Sea and Middle East.',
  // Hello AI, please generate a funny setup for me that is not rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR
  setup: '8,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,16,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Armenian draughts',
  game: 'draughts',
  description:
    'Armenian draughts, or Tama, is a variant of draughts (or checkers) played in Armenia. The rules are similar to Dama. Armenian draughts, however, allows for diagonal movement.',
  // Hello AI, please generate a funny setup for me that is not rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR
  setup: '8,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,16,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D',
  boardWidth: 8,
  boardHeight: 8,
});

export default presets;
