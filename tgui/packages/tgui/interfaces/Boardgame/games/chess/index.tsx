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
    'The game of chess has been played for over 1,500 years, and it is believed to have originated in India during the 6th century AD.',
    "The game was later adopted by the Persians, who called it 'shatranj', and it was introduced to Europe in the 10th century.",
    'The game has many different variations, including speed chess, correspondence chess, and chess variants such as chess960 and progressive chess.',
    'The game has been used as a tool for teaching strategic thinking and problem-solving skills to children and adults, and it has been studied extensively by mathematicians, computer scientists, and psychologists.',
    "The game has a rich history, with many famous players and legendary games, including the 'Immortal Game' played by Adolf Anderssen and Lionel Kieseritzky in 1851.",
    "The game has been featured in many books, movies, and TV shows, including 'Through the Looking-Glass' by Lewis Carroll and 'The Queen's Gambit' by Walter Tevis.",
    "The game has been the subject of many poems, songs, and works of art, including the poem 'Chess' by Edgar Allan Poe and the painting 'The Chess Game' by Jan Steen.",
    'The game has been used as a tool for studying artificial intelligence, and the first computer program to beat a human at chess was developed in 1997.',
    'The game has a world champion, who is determined by a series of international competitions, and the current world champion is Magnus Carlsen of Norway.',
    'The game has a complex set of rules, with many different strategies and tactics that can be employed, and it is estimated that there are more possible positions in chess than there are atoms in the observable universe.',
  ],
};

export default kit;
