import { PresetType } from '../..';

const chess960: PresetType = {
  name: 'Chess960',
  game: 'chess',
  description: 'Chess with random starting positions.',
  setup: function () {
    let pieces = 'XXXXXXXX'.split('');

    // Place the kings

    return '';
  },
  boardWidth: 8,
  boardHeight: 8,
};
