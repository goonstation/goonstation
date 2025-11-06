/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @license ISC
 */

import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface HostConnectionStatus {
  host_connection;
}

export const Telepad = () => {
  const { act, data } = useBackend<HostConnectionStatus>();
  const { host_connection } = data;
  return (
    <Window title="Telepad" width={350} height={150} theme="ntos">
      <Window.Content>
        <Section title="Host Connection">
          <Box
            textAlign="center"
            fontSize={2}
            textColor={host_connection ? 'green' : 'red'}
          >
            {host_connection ? 'CONNECTED' : 'NO CONNECTION'}
          </Box>
          <Box textAlign="center" pt={0.5}>
            <Button color="blue" onClick={() => act('reset_connection')}>
              Reset connection
            </Button>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
