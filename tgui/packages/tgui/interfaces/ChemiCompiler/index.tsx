/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { Window } from '../../layouts';
import { ChemiCompilerTextArea } from './ChemiCompilerTextArea';
import { ChemiCompilerReservoirs } from './ChemiCompilerReservoirs';
import { ChemiCompilerMemory } from './ChemiCompilerMemory';
import { Stack } from '../../components';

export const ChemiCompiler = (_props, _context) => {
  return (
    <Window width={600} height={475}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <ChemiCompilerTextArea />
          </Stack.Item>
          <Stack.Item basis={18} textAlign="center">
            <ChemiCompilerReservoirs />
            <ChemiCompilerMemory />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
