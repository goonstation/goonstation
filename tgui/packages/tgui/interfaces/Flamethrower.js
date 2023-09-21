import { useBackend } from '../backend';
import { PortableHoldingTank } from './common/PortableAtmos';
import { Button, Stack, Knob, Box, Icon, AnimatedNumber, Section, NumberInput } from '../components';
import { ReagentBar } from './common/ReagentInfo';
import { getTemperatureColor, getTemperatureIcon, freezeTemperature } from './common/temperatureUtils';
import { Window } from '../layouts';

const PilotLight = (props, context) => {
  const { act } = useBackend(context);
  const {
    lit,
    maxTemp,
    minTemp,
    sprayTemp,
  } = props;
  return (
    <Section fill title="Pilot Light">
      <Stack justify="center" align="center">
        <Stack.Item>
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
        </Stack.Item>
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
            <Box fontSize={1}>Temperature</Box>
            <Icon name={getTemperatureIcon(sprayTemp)} pr={0.5} />
            <AnimatedNumber
              value={Math.floor(sprayTemp - freezeTemperature)}
            />
            C
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const FuelControl = (props, context) => {
  const { act } = useBackend(context);
  const {
    mode,
    minVolume,
    maxVolume,
    chamberVolume,
  } = props;
  return (
    <Section fill title="Fuel Control">
      <Stack vertical>
        <Stack.Item>
          {"Fire mode: "}
          <Button selected={mode === 'auto'} onClick={() => act('change_mode', { mode: 'auto' })}>Full Auto</Button>
          <Button selected={mode === 'burst'} onClick={() => act('change_mode', { mode: 'burst' })}>Wide Burst</Button>
          <Button selected={mode === 'semi_auto'} onClick={() => act('change_mode', { mode: 'semi_auto' })}>Semi Auto</Button>
        </Stack.Item>
        <Stack.Item>
          {"Chamber volume: "}
          <NumberInput
            value={chamberVolume}
            minValue={minVolume}
            maxValue={maxVolume}
            onChange={(e, value) => act('change_volume', { volume: value })}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const Flamethrower = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    gasTank,
    fuelTank,
  } = data;
  return (
    <Window
      width={580}
      height={270}
      theme="ntos"
      title="Flamethrower"
    >
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Stack justify="center">
              <Stack.Item width="21em">
                <PilotLight {...data} />
              </Stack.Item>
              <Stack.Item grow>
                <FuelControl {...data} />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item width="21em">
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
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
