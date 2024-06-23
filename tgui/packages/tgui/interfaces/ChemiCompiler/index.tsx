/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { Window } from '../../layouts';
import { useBackend } from '../../backend';
import { ChemiCompilerData } from './type';
import { ChemiCompilerTextArea } from './ChemiCompilerTextArea';
import { ChemiCompilerReservoirs } from './ChemiCompilerReservoirs';
import { ChemiCompilerMemory } from './ChemiCompilerMemory';
import { Stack } from '../../components';

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
