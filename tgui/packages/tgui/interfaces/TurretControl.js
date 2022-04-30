import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Flex, Box, Stack } from '../components';

export const TurretControl = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    enabled,
    lethal,
    emagged,
    area,
  } = data;

  const set_lethal = (value) => {
    if (value === !!lethal) {
      return;
    }
    act("setLethal", { "lethal": value });
  };
  const set_enabled = (value) => {
    if (value === !!enabled) {
      return;
    }
    act("setEnabled", { "enabled": value });
  };
  return (
    <Window
      title={emagged ? "FATAL ERROR" : "Turret control (" + area + ")"}
      theme={emagged ? 'syndicate' : 'ntos'}
      width={400}
      height={160}
    >
      <Window.Content align="center">
        <br />
        {!emagged && (
          <Box>
            <Section width="50%">
              <Stack>
                <Stack.Item width="50%">
                  <Button icon="exclamation-triangle" fluid selected={enabled} onClick={() => set_enabled(true)}>Enabled</Button>
                </Stack.Item>
                <Stack.Item width="50%">
                  <Button icon="power-off" fluid selected={!enabled} onClick={() => set_enabled(false)}>Disabled</Button>
                </Stack.Item>
              </Stack>
            </Section>
            <Section width="50%">
              <Stack>
                <Stack.Item width="50%">
                  <Button icon="bolt" fluid selected={!lethal} onClick={() => set_lethal(false)}>Stun</Button>
                </Stack.Item>
                <Stack.Item width="50%">
                  <Button icon="skull-crossbones" fluid selected={lethal} onClick={() => set_lethal(true)}>Lethal</Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Box>
        )}
        {emagged === 1 && (
          <Box>
            <Box align="center" fontFamily="Courier New">
              ER{"{"}ROR: UNABLE TO R$EAD %{"{"}param{"}"} AUTH${"{"}OR\IZ#2A6F%
            </Box>
            <Box align="center" fontSize="16px">
              Kill. Kill. Kill. Kill. Kill. Kill. Kill.
            </Box>
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};
