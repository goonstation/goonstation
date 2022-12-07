/* eslint-disable react/no-unescaped-entities */
/* @ts-ignore */

import { PresetType } from '../..';
import { Box, Stack } from '../../../../../components';

const presets: PresetType[] = [];

/* Chess */

presets.push({
  name: 'Chess',
  game: 'chess',
  description: 'The classic game of chess.',
  rules: (
    // Write the rules in a readable format
    <Stack vertical>
      <Stack.Item>
        <Box bold>Objective</Box>
        <Box>Checkmate the opponents king.</Box>
      </Stack.Item>
      <Stack.Item>
        <Box bold>Setup</Box>
        <Box>
          Each player starts with 16 pieces: 1 king, 1 queen, 2 rooks, 2 bishops, 2 knights, and 8 pawns. The pieces are
          set up on the back rank, with the pawns on the second rank.
        </Box>
      </Stack.Item>
      <Stack.Item>
        <Box bold>Gameplay</Box>
        <Box>
          Players take turns moving one of their pieces. A move is legal if it does not put the players king in check. A
          player can only move a piece if it is their turn. A player can only move a piece if it is their turn. If a
          players king is in check, they must move it out of check. If a players king is in checkmate, they lose. If a
          players king is in stalemate, the game is a draw.
        </Box>
      </Stack.Item>
    </Stack>
  ),
  setup: 'r,n,b,q,k,b,n,r,p,p,p,p,p,p,p,p,32,P,P,P,P,P,P,P,P,R,N,B,Q,K,B,N,R',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Charge of the Light Brigade',
  game: 'chess',
  description: 'Apart from the usual king and pawns, one side has three queens and the other has seven knights.',
  setup: 'n,n,n,n,k,n,n,n,p,p,p,p,p,p,p,p,32,P,P,P,P,P,P,P,P,1,Q,1,Q,K,1,Q,1',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Horde',
  game: 'chess',
  description:
    "In this variant, White's pawns on the first and second ranks may advance one or two steps, provided that the path in the file is free. Unlike in regular chess, this does not have to be the pawn's first move",
  setup:
    'r,n,b,q,k,b,n,r,p,p,p,p,p,p,p,p,8,1,P,P,2,P,P,1,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Racing Kings',
  game: 'chess',
  description:
    "In Racing Kings the object is not to trap or capture your opponent's king, but instead it is a race to the 8th rank! ",
  setup: '48,k,r,b,n,N,B,R,K,q,r,b,n,N,B,R,Q',
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: 'Displacement chess',
  game: 'chess',
  description:
    "Displacement chess is a family of chess variants in which a few pieces are transposed in the initial standard chess position. The main goal of these variants is to negate players' knowledge of standard chess openings.",
  setup: function () {
    let board: (number | string[])[] = [];

    const pawns = ['p', 'p', 'p', 'p', 'p', 'p', 'p', 'p'];
    let special = ['n', 'b', 'r', 'q', 'k', 'r', 'b', 'n'];

    // Shuffle the special pieces
    for (let i = special.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [special[i], special[j]] = [special[j], special[i]];
    }

    board.push(special);
    board.push(pawns);
    board.push(32);
    board.push(pawns.map(() => 'P'));
    board.push(special.map((v) => v.toUpperCase()));

    return board.join(',');
  },
  boardWidth: 8,
  boardHeight: 8,
});

presets.push({
  name: "Dunsany's Chess by Lord Dunsany",
  game: 'chess',
  description: '(and the similar Horde chess): One side has standard chess pieces, and the other side has 32 pawns.',
  setup: 'r,n,b,q,k,b,n,r,p,p,p,p,p,p,p,p,16,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P',
  boardWidth: 8,
  boardHeight: 8,
});

export default presets;
