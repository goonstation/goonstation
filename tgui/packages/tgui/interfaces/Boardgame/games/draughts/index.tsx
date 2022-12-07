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
    "The first game of draughts was played between two crocodiles, who used their sharp teeth to capture the opponent's pieces.",
    'The king piece was originally the weakest piece on the board, but was later granted extra powers after threatening to leave the game and start his own version of draughts.',
    "In some ancient cultures, losing a game of draughts was punishable by banishment. This led to the development of the 'draughts-bot,' a robot that would take the fall for human players who didn't want to risk their social standing.",
    "The game of draughts was originally called 'The Royal Game of Lizards,' but was changed to its current name after a group of disgruntled snakes complained about the lack of representation.",
    'The draughtsboard is actually a giant, magical time machine. Each square on the board represents a different time period, and when a piece moves to a new square, it is instantly transported to that era.',
    "The most powerful move in draughts is called the 'dragon,' which involves sacrificing all of your pieces to summon a giant, fire-breathing dragon that can move anywhere on the board and destroy any piece in its path.",
    'The longest game of draughts ever recorded lasted for over 1,000 years, as the two players were both immortal and refused to give up.',
    'The game of draughts was originally played with live insects, but this was deemed too cruel and was eventually replaced with carved wooden pieces.',
    'In some parts of the world, draughts is played with playing cards instead of pieces. Each card drawn determines which piece can move and where it can go.',
    'The first draughts champion was a cockroach, who was able to outsmart all of the human players with its superior speed and ability to squeeze through tight spaces.',
  ],
};

export default kit;
