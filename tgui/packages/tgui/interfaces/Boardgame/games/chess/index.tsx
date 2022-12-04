import { GameKit } from '..';
import pieces from './pieces';
import presets from './presets';

// Export as gamekit module, use type GameKit
export const kit: GameKit = {
  pieces,
  presets,
  palettes: [
    {
      name: 'Chess',
      pieces,
    },
  ],
  // Generate 10 fun facts about chess
  facts: ['This is a very long fact, chess is a very long game, and it is very fun to play and watch.'],
};

export default kit;
