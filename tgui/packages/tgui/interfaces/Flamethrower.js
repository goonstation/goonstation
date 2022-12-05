import { useBackend } from '../backend';
import { PortableHoldingTank } from './common/PortableAtmos';
import { Button, Stack, Knob, Box, Icon, AnimatedNumber, Section, NumberInput } from '../components';
import { ReagentBar } from './common/ReagentInfo';
import { getTemperatureColor, getTemperatureIcon, freezeTemperature } from './common/temperatureUtils';
import { Window } from '../layouts';

export const Flamethrower = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    lit,
    maxTemp,
    minTemp,
    sprayTemp,
    mode,
    gasTank,
    fuelTank,
    minVolume,
    maxVolume,
    chamberVolume,
  } = data;
  return (
    <Window
      width={500}
      height={260}
    >
      <Window.Content>
        <Stack justify="center">
          <Stack.Item width="50%">
            <Section fill align="center">
              <Button
                icon="fire"
                color={lit ? "orange" : null}
                iconColor={lit ? "yellow" : null}
                onClick={() => act('light')}
                align="center"
                width="5em"
                fontSize={1.25}
              >
                {lit ? "Lit" : "Unlit"}
              </Button>
              <Stack justify="center">
                <Stack.Item>
                  <Button selected={mode === 'auto'} width="100%" onClick={() => act('change_mode', { mode: 'auto' })}>Full Auto</Button>
                </Stack.Item>
                <Stack.Item>
                  <Button selected={mode === 'burst'} width="100%" onClick={() => act('change_mode', { mode: 'burst' })}>Wide Burst</Button>
                </Stack.Item>
                <Stack.Item>
                  <Button selected={mode === 'semi_auto'} width="100%" onClick={() => act('change_mode', { mode: 'semi_auto' })}>Semi Auto</Button>
                </Stack.Item>
              </Stack>
              Chamber volume:
              <NumberInput
                value={chamberVolume}
                minValue={minVolume}
                maxValue={maxVolume}
                onChange={(e, value) => act('change_volume', { volume: value })}
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill>
              <Stack justify="center">
                <Stack.Item>
                  <Knob
                    animated
                    size={2}
                    value={sprayTemp}
                    minValue={minTemp}
                    maxValue={maxTemp}
                    format={value => Math.floor(value - freezeTemperature) + " C"}
                    onChange={(e, value) => act('change_temperature', { temperature: (value) })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Box
                    className="ChemHeater__TemperatureNumber"
                    nowrap
                    p={1}
                    fontSize={1.5}
                    color={getTemperatureColor(sprayTemp)}
                    backgroundColor="black">
                    <Box fontSize={1}>Spray Temp</Box>
                    <Icon name={getTemperatureIcon(sprayTemp)} pr={0.5} />
                    <AnimatedNumber
                      value={Math.floor(sprayTemp - freezeTemperature)}
                    />
                    C
                  </Box>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
        <br />
        <Stack>
          <Stack.Item width="50%">
            <PortableHoldingTank
              title="Gas Tank"
              holding={gasTank}
              onEjectTank={() => act('remove_gas')}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Section
              title="Fuel Tank"
              fill
              buttons={(
                <Button
                  icon="eject"
                  content="Eject"
                  disabled={!fuelTank}
                  onClick={() => act('remove_fuel')} />
              )}
            >
              {fuelTank
              && <ReagentBar container={fuelTank} height="5em" /> }
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
