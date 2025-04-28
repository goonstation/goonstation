/**
 * @file
 * @copyright 2025
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */

import { Button, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { formatPower } from '../../format';
import { Window } from '../../layouts';

export const CurrentTurbine = () => {
  const { act, data } = useBackend<CurrentTurbineData>();
  return (
    <Window title="Turbine controls" width={300} height={100}>
      <Window.Content>
        <Stack vertical width="100%">
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <Button width="100%" onClick={() => act('extend')}>
                  Extend
                </Button>
              </Stack.Item>
              <Stack.Item grow>
                <Button width="100%" onClick={() => act('retract')}>
                  Retract
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Stack align="baseline">
              <Stack.Item grow>
                <Button
                  width="100%"
                  onClick={() => act('reverse')}
                  icon={data.reversed ? 'toggle-on' : 'toggle-off'}
                >
                  Reverse stator
                </Button>
              </Stack.Item>
              <Stack.Item grow>
                Generation: {formatPower(data.generation)}
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
