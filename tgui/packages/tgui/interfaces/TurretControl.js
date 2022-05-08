import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Flex, Box, Stack } from '../components';

const randInt = (a, b) => {
  if (a > b) {
    let temp = a;
    a = b;
    b = temp;
  }
  return Math.floor(Math.random() * (b - a + 1)) + a;
};

// this is a totally real and normal semicolon I promise
const glitches = ['$', '{', ']', '%', '^', '?', '>', '¬', 'π', ';', 'и', 'ю', '/', '#', '~'];
const glitch = (text, amount) => {
  for (let i = 0; i < amount; i++) {
    let index = randInt(0, text.length);
    text = text.slice(0, index) + glitches[randInt(0, glitches.length - 1)] + text.slice(index, text.length);
  }
  return text;
};

const generate_kill = (number) => {
  let out = [];
  for (let i = 0; i < 7; i++) {
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
          {!emagged && locked === 1 && (
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
