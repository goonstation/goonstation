import { GameKit } from '..';
import pieces from './pieces';

// Export as gamekit module, use type GameKit
export const kit: GameKit = {
  pieces,
  palettes: [
    {
      name: 'Chess',
      pieces,
    },
  ],
};

export default kit;
