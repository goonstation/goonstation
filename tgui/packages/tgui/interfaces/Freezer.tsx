/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import {
  AnimatedNumber,
  Box,
  Button,
  Icon,
  Knob,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { formatPressure } from '../format';
import { Window } from '../layouts';
import {
  getTemperatureColor,
  getTemperatureIcon,
} from './common/temperatureUtils';

type FreezerData = {
  active: number;
  target_temperature: number;
  air_temperature: number;
  air_pressure: number;
};

export const Freezer = () => {
  const { act, data } = useBackend<FreezerData>();
  const { target_temperature, active, air_temperature, air_pressure } = data;

  return (
    <Window title="Freezer" width={320} height={215}>
      <Window.Content>
        <Section title="Temperature Control">
          <Stack align="center">
            <Stack.Item>
              <Knob
                animated
                size={2}
                value={target_temperature}
                minValue={73.15}
                maxValue={293.15}
                format={(value) => value + ' K'}
                onChange={(_e, value) =>
                  act('set_target_temperature', { value: value })
                }
              />
            </Stack.Item>
            <Stack.Item grow basis={0} overflow="hidden">
              <Box
                className="ChemHeater__TemperatureNumber"
                nowrap
                p={1}
                fontSize={1.5}
                color={getTemperatureColor(target_temperature)}
                backgroundColor="black"
              >
                <Box fontSize={1}>Target</Box>
                <Icon name={getTemperatureIcon(target_temperature)} pr={0.5} />
                <AnimatedNumber value={target_temperature} /> K
              </Box>
            </Stack.Item>
            <Stack.Item basis={9.6} align="center">
              <Button
                icon="power-off"
                color={active === 0 ? 'red' : 'green'}
                fluid
                height="100%"
                fontSize={1.15}
                textAlign="center"
                onClick={() => act('active_toggle')}
              >
                {active === 0 ? 'Deactivated' : 'Activated'}
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
        <Section>
          <Stack align="center">
            <Stack.Item>
              <Box
                className="ChemHeater__TemperatureNumber"
                nowrap
                p={1}
                width="50%"
                fontSize={1.3}
                color={getTemperatureColor(air_temperature)}
              >
                <Box fontSize={1}>Current Temperature</Box>
                <Icon name={getTemperatureIcon(air_temperature)} pr={0.5} />
                <AnimatedNumber value={air_temperature} /> K
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Box nowrap p={1} width="50%" fontSize={1.3}>
                <Box fontSize={1}>Current Pressure</Box>
                <AnimatedNumber value={air_pressure} format={formatPressure} />
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
