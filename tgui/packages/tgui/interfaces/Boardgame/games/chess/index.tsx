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
  facts: [
    'The first game of chess was played between two elephants, who used their trunks to move the pieces.',
    'The queen was originally the weakest piece on the board, but was later granted extra powers after threatening to leave the game and start her own version of chess.',
    "In some ancient cultures, losing a game of chess was punishable by death. This led to the development of the 'chess-bot,' a robot that would take the fall for human players who didn't want to risk their lives.",
    "The game of chess was originally called 'The Royal Game of Beavers,' but was changed to its current name after a group of disgruntled rabbits complained about the lack of representation.",
    'The chessboard is actually a giant, magical teleportation device. Each square on the board represents a different location, and when a piece moves to a new square, it is instantly transported to that location.',
    "The most powerful move in chess is called the 'unicorn,' which involves sacrificing all of your pieces to summon a giant, flying unicorn that can move anywhere on the board and destroy any piece in its path.",
    'The longest game of chess ever recorded lasted for over 100 years, as the two players were both immortal and refused to give up.',
    'The game of chess was originally played with live animals, but this was deemed too cruel and was eventually replaced with carved wooden pieces.',
    'In some parts of the world, chess is played with dice instead of pieces. Each roll of the dice determines which piece can move and where it can go.',
    'The first chess champion was a chicken, who was able to outsmart all of the human players with its superior logic and strategic egg-laying abilities.',
  ],
};

export default kit;
