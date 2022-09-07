import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Button, Section, Box, Stack } from '../components';
import { randInt } from './common/mathUtils';
import { glitch } from './common/stringUtils';

const generate_kill = (number) => {
  let out = [];
  for (let i = 0; i < number; i++) {
    if (Math.random() > 0.3) {
      out.push("Kill. ");
    } else {
      out.push("KILL. ");
    }
  }
  return out.map((kill, index) => (<Box inline preserveWhitespace fontSize={randInt(11, 25) + "px"} key={index}>{kill}</Box>));
};

export const TurretControl = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    enabled,
    lethal,
    emagged,
    area,
    locked,
  } = data;

  const set_lethal = (value) => {
    act("setLethal", { "lethal": value });
  };
  const set_enabled = (value) => {
    act("setEnabled", { "enabled": value });
  };
  return (
    <Window
      title={emagged ? "FATAL ERROR" : `Turret control (${area})`}
      theme={emagged ? 'syndicate' : 'ntos'}
      width={400}
      height={160}
    >
      <Window.Content align="center">
        <Box py="6px">
          {(!emagged && !locked) && (
            <Box fontSize="16px">
              <Section width="70%">
                <Stack>
                  <Stack.Item width="50%">
                    <Button icon="exclamation-triangle" fluid selected={enabled} onClick={() => set_enabled(true)}>Enabled</Button>
                  </Stack.Item>
                  <Stack.Item width="50%">
                    <Button icon="power-off" fluid selected={!enabled} onClick={() => set_enabled(false)}>Disabled</Button>
                  </Stack.Item>
                </Stack>
              </Section>
              <Section width="70%">
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
          {!emagged && !!locked && (
            <Section>Panel locked, swipe ID card to unlock.</Section>
          )}
          {!!emagged && (
            <Box py="20px">
              <Box align="center" fontFamily="Courier New">
                {glitch("ERROR: UNABLE TO READ AUTHORIZATION", 12)}
              </Box>
              <Box align="center" style={{ "font-size": "20px" }}>
                {generate_kill(7)}
              </Box>
            </Box>
          )}
        </Box>
      </Window.Content>
    </Window>
  );
};
