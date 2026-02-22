/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { ChemiCompilerMemory } from './ChemiCompilerMemory';
import { ChemiCompilerReservoirs } from './ChemiCompilerReservoirs';
import { ChemiCompilerTextArea } from './ChemiCompilerTextArea';
import { ChemiCompilerData } from './type';

const SIDEBAR_WIDTH = 18;

export const ChemiCompiler = () => {
  const { data } = useBackend<ChemiCompilerData>();
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
