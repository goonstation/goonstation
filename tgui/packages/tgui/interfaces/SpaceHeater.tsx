/**
 * @file
 * @copyright 2024
 * @author IPingu (https://github.com/IPling)
 * @license ISC
 */

import {
  Button,
  Divider,
  LabeledList,
  ProgressBar,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { glitch } from './common/stringUtils';
import { neutralTemperature } from './common/temperatureUtils';

const Glitch_Text = (emagged, string, number) => {
  if (emagged) {
    return glitch(string, number);
  } else {
    return string;
  }
};

const Set_Color = (temperature, generic_color = '') => {
  if (temperature > 400) {
    return 'red';
  } else if (temperature < 180) {
    return 'blue';
  } else {
    return generic_color;
  }
};

const Set_Icon = (emagged, temperature, on) => {
  if (!emagged) {
    return 'eject';
  } else if (temperature < 180 && on) {
    return 'snowflake';
  } // Under 100 kelvin is supercooling
  else if (temperature > 400 && on) {
    return 'fire';
  } // Over 400 kelvin is overheating
  else {
    return 'eject';
  }
};

interface SpaceHeaterData {
  cell;
  cell_charge;
  cell_name;
  emagged;
  max;
  min;
  on;
  set_temperature;
}

export const SpaceHeater = () => {
  const { data } = useBackend<SpaceHeaterData>();
  const { emagged } = data;
  return (
    <Window
      title={emagged ? Glitch_Text(emagged, 'Space HVAC', 1) : null} // null lets us use the src.name at the time of ui_interact
      width={350}
      height={250}
    >
      <Window.Content>
        <BatteryStatus />
        <TemperatureRegulator />
      </Window.Content>
    </Window>
  );
};

const BatteryStatus = () => {
  const { data, act } = useBackend<SpaceHeaterData>();
  const { emagged, on, cell, cell_name, cell_charge, set_temperature } = data;
  return (
    <Section title={Glitch_Text(emagged, 'Battery status', 2)}>
      <LabeledList>
        <LabeledList.Item
          label={Glitch_Text(emagged, 'Cell', 1)}
          verticalAlign={'middle'}
        >
          <Button
            icon={Set_Icon(emagged, set_temperature, on)}
            color={cell !== null ? Set_Color(set_temperature, 'green') : 'blue'}
            onClick={() =>
              cell !== null ? act('cellremove') : act('cellinstall')
            }
            bold
          >
            {cell !== null
              ? Glitch_Text(emagged, cell_name, 2)
              : Glitch_Text(emagged, 'Insert power cell', 3)}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item
          label={Glitch_Text(emagged, 'Cell Power', 1)}
          verticalAlign={'middle'}
        >
          <ProgressBar
            color={cell !== null ? Set_Color(set_temperature, 'green') : 'red'}
            ranges={{
              green: [0.5, Infinity],
              yellow: [0.1, 0.5],
              red: [-Infinity, 0.1],
            }}
            value={Math.max(0, cell !== null ? cell_charge / 100 : 0)}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const TemperatureRegulator = () => {
  const { data, act } = useBackend<SpaceHeaterData>();
  const { emagged, min, max, set_temperature } = data;
  return (
    <Section title={Glitch_Text(emagged, 'Temperature regulator', 3)}>
      <Stack justify="center" align="center">
        <Stack.Item>
          <Button
            icon={'fast-backward'}
            color={Set_Color(set_temperature)}
            tooltip={'Set minimum'}
            disabled={set_temperature === min}
            onClick={() => act('set_temp', { inputted_temperature: min })}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={'backward'}
            color={Set_Color(set_temperature)}
            tooltip={emagged ? 'Decrease by 50' : 'Decrease by 5'}
            disabled={set_temperature === min}
            onClick={() =>
              act('set_temp', { temperature_adjust: emagged ? -50 : -5 })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={'equals'}
            color={Set_Color(set_temperature)}
            tooltip={'Room temperature'}
            onClick={() =>
              act('set_temp', { inputted_temperature: neutralTemperature })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={'forward'}
            color={Set_Color(set_temperature)}
            tooltip={emagged ? 'Increase by 50' : 'Increase by 5'}
            disabled={set_temperature === max}
            onClick={() =>
              act('set_temp', { temperature_adjust: emagged ? 50 : 5 })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={'fast-forward'}
            color={Set_Color(set_temperature)}
            tooltip={'Set maximum'}
            disabled={set_temperature === max}
            onClick={() => act('set_temp', { inputted_temperature: max })}
          />
        </Stack.Item>
      </Stack>
      <Divider />
      <Slider
        value={set_temperature}
        format={(value) => value + ' K'}
        minValue={min}
        maxValue={max}
        step={emagged ? 5 : 1}
        stepPixelSize={emagged ? 3 : 1.8}
        ranges={{
          blue: [-Infinity, neutralTemperature - 1], // Specifically want neutralTemperature (293.15) to be considered 'warm'
          red: [neutralTemperature, Infinity],
        }}
        onChange={(e, value) =>
          act('set_temp', { inputted_temperature: value })
        }
      />
    </Section>
  );
};
