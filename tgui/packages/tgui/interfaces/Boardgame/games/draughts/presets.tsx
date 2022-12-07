import { PresetType } from '..';

const presets: PresetType[] = [];

/* Draughts */

presets.push({
  name: 'Draughts',
  game: 'draughts',
  description:
    "Draughts is a game of strategy and skill for two players. It is played on an 8x8 board with 12 pieces on each side. The pieces move diagonally, one square at a time. The objective is to capture all of your opponent's pieces or to block them so that they cannot move.",
  setup: '1,d,1,d,1,d,1,d,d,1,d,1,d,1,d,2,d,1,d,1,d,1,d,16,D,1,D,1,D,1,D,2,D,1,D,1,D,1,D,D,1,D,1,D,1,D',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Dameo',
  game: 'draughts',
  description:
    'Dameo is an abstract strategy board game for two players invented by Christian Freeling in 2000. It is a variant of the game draughts.',
  setup: 'd,d,d,d,d,d,d,d,1,d,d,d,d,d,d,3,d,d,d,d,20,D,D,D,D,3,D,D,D,D,D,D,1,D,D,D,D,D,D,D,D',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Turkish draughts',
  game: 'draughts',
  description:
    'Turkish draughts (also known as Dama) is a variant of draughts played in Turkey, Greece, Egypt, Kuwait, Lebanon, Syria, Jordan and several other locations around the Mediterranean Sea and Middle East.',
  setup: '8,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,16,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Right angels',
  game: 'draughts',
  description: 'Two right angel shaped formations per player.',
  setup: 'd,3,d,2,d,1,d,1,d,2,d,3,d,2,d,2,D,5,d,2,D,5,d,2,D,2,D,3,D,2,D,1,D,1,D,2,D,3,D',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Empty middle',
  game: 'draughts',
  description: 'This setup creates an empty diamond shape in the middle.',
  setup: 'd,d,d,d,d,d,d,d,d,d,d,2,d,d,d,d,d,4,d,d,d,6,d,D,6,D,D,D,4,D,D,D,D,D,2,D,D,D,D,D,D,D,D,D,D,D',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Column of pieces',
  game: 'draughts',
  description: 'Gives each player four 1x3 columns of pieces.',
  setup: '1,d,1,d,1,d,1,d,1,d,1,d,1,d,1,d,1,d,1,d,1,d,1,d,16,D,1,D,1,D,1,D,1,D,1,D,1,D,1,D,1,D,1,D,1,D,1,D',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Groups of four',
  game: 'draughts',
  description: 'Gives each player three 2x2 groups of pieces.',
  setup: '6,d,d,3,d,d,1,d,d,d,d,1,d,d,3,d,d,12,D,D,3,D,D,1,D,D,D,D,1,D,D,3,D,D',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Smile vs smile',
  game: 'draughts',
  description: 'Gives each player a smiley face of pieces.',
  setup: '2,d,2,d,2,d,6,d,1,d,d,d,d,d,d,18,D,D,D,D,D,D,1,D,6,D,2,D,2,D',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Two divisions',
  game: 'draughts',
  description: 'Each player gets Two 3x3 groups of pieces.',
  setup: 'd,d,d,2,d,d,d,d,d,d,2,d,d,d,d,d,d,2,d,d,d,16,D,D,D,2,D,D,D,D,D,D,2,D,D,D,D,D,D,2,D,D,D',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Penetrated frontlines',
  game: 'draughts',
  description: 'Both players have a 2x3 group of pieces a bit further in, while 4 on each side are staying behind.',
  setup: '4,d,d,d,d,9,d,d,6,d,d,2,D,D,2,d,d,2,D,D,6,D,D,9,D,D,D,D',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Fight club',
  game: 'draughts',
  description: 'Both players surround the middle like a circle.',
  setup: '10,d,d,d,d,3,d,4,d,2,d,4,d,2,D,4,D,2,D,4,D,3,D,D,D,D',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'One big vs two small',
  game: 'draughts',
  description: 'One player has a big 4x3 group of pieces, while the other has two 2x3.',
  setup: '2,d,d,d,d,4,d,d,d,d,4,d,d,d,d,18,D,D,4,D,D,D,D,4,D,D,D,D,4,D,D',
  boardWidth: 8,
  boardHeight: 8,
});

export default presets;
