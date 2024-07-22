/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { Stack } from '../../components';
import { Window } from '../../layouts';
import { ChemiCompilerMemory } from './ChemiCompilerMemory';
import { ChemiCompilerReservoirs } from './ChemiCompilerReservoirs';
import { ChemiCompilerTextArea } from './ChemiCompilerTextArea';
import { ChemiCompilerData } from './type';

const SIDEBAR_WIDTH = 18;

export const ChemiCompiler = (_props, context) => {
  const { data } = useBackend<ChemiCompilerData>(context);
  const { theme } = data;
  return (
    <Window width={600} height={500} theme={theme}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <ChemiCompilerTextArea />
          </Stack.Item>
          <Stack.Item basis={SIDEBAR_WIDTH} textAlign="center">
            <ChemiCompilerReservoirs />
            <ChemiCompilerMemory />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
