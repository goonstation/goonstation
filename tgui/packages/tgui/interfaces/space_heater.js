/**
 * @file
 * @copyright 2024
 * @author IPingu (https://github.com/IPling)
 * @license ISC
 */

// Notes: Change icons to the respective emag variants, give glitch affects to emag variants
// Supercooling and Overheating emag affects.
// Supercooling: Blue coloring to buttons and loading bar, picklocking affect for taking out the power cell.
// Overheating: Red coloring to buttons and loading bar, power cell burns player when taken out.

import { useBackend } from '../backend';
import { Box, Button, Divider, Flex, Icon, LabeledList, Modal, ProgressBar, Section, Slider, Stack } from '../components';
import { Window } from '../layouts';
import { randInt } from './common/mathUtils';
import { glitch } from './common/stringUtils';

const Glitch_Text = (emagged, string, number) => {
  if (emagged) {
    return glitch(string, number);
  } else {
    return string;
  }
};
// Used for well, finding the theme, but also to tell if its in the 'special variants' when emagged.
const Find_Theme = (emagged, temperature, on) => {
  if (!emagged) { return "generic"; }
  else if (temperature < 100 && on) { return "ntos"; } // Under 100 kelvin is supercooling
  else if (temperature > 400 && on) { return "syndicate"; } // Over 400 kelvin is overheating
  else { return "generic"; }
};

const HVAC_Death = (emagged, cell, cell_charge) => {
  if ((cell === null || cell_charge === 0) && emagged) {
    return true;
  }
  return false;
};

const Set_Color = (temperature, generic_color="", on=true) => {
  if (temperature > 400 && on) {
    return "red";
  } else if (temperature < 100 && on) {
    return "blue";
  } else {
    return generic_color;
  }
};

const Set_Icon = (theme) => {
  if (theme === "generic") {
    return "eject";
  } else if (theme === "syndicate") {
    return "fire";
  } else {
    return "snowflake";
  }
};

const Generate_Emag_Text = (theme, number) => {
  let out = [];
  if (theme === "generic") {
    for (let i = 0; i < number; i++) {
      if (Math.random() > 0.3) {
        out.push("ERROR ");
      } else {
        out.push("Error ");
      }
    }
    return out.map((kill, index) => (
      <Box inline preserveWhitespace color="red" fontSize={randInt(10, 25) + "px"} key={index}>{kill}</Box>
    ));
  }
  for (let i = 0; i < number; i++) {
    let num = Math.random();
    if (num < 0.2) {
      out.push(theme === "syndicate" ? "HOT! HOT! HOT! ": "so cold... ");
    } else if (0.2 < num < 0.4) {
      out.push(theme === "syndicate" ? "IM BURNING! ": "im freezing... ");
    } else if (0.4 < num < 0.6) {
      out.push(theme === "syndicate" ? "HELP! ": "im shivering... ");
    } else if (0.6 < num < 0.8) {
      out.push(theme === "syndicate" ? "MELTING! ": "its so cold... ");
    } else {
      out.push(theme === "syndicate" ? "OVERHEATING! ": "chilly... ");
    }
  }
  return out.map((kill, index) => (
    <Box inline preserveWhitespace fontSize={randInt(10, 16) + "px"} key={index}>{kill}</Box>
  ));
};

export const space_heater = (props, context) => {
  const { data } = useBackend(context);
  const {
    emagged,
    on,
    cell,
    cell_charge,
    set_temperature,
  } = data;
  return (
    <Window
      title={Glitch_Text(emagged, "Space HVAC", 1)}
      theme={Find_Theme(emagged, set_temperature, on)}
      width={350}
      height={250}>
      <Window.Content>
        {HVAC_Death(emagged, cell, cell_charge) && (
          <Modal
            Align="center"
            width={30.5}
            height={18}
          >
            <Box backgroundColor={Set_Color(set_temperature, "#001414")}>
              <Icon name={"skull-crossbones"} size={15} />
            </Box>
          </Modal>
        )}
        <BatteryStatus />
        <TemperatureRegulator />
      </Window.Content>
    </Window>
  );
};

const BatteryStatus = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    emagged,
    on,
    cell,
    cell_name,
    cell_charge,
    set_temperature,
  } = data;
  return (
    <Section title={Glitch_Text(emagged, "Battery status", 2)} grow={0}>
      <LabeledList>
        <LabeledList.Item
          label={Glitch_Text(emagged, "Cell", 1)}
          verticalAlign={"middle"}
        >
          <Flex justify={"space-between"}>
            <Flex.Item>
              <Button
                icon={Set_Icon(Find_Theme(emagged, set_temperature, on))}
                color={cell !== null ? Set_Color(set_temperature, "green", on) : "blue"}
                disabled={on && !emagged}
                onClick={() => cell !== null ? act('cellremove'): act('cellinstall')}
                bold>
                {cell !== null ? Glitch_Text(emagged, cell_name, 2): Glitch_Text(emagged, "Insert power cell", 3)}
              </Button>
            </Flex.Item>
            <Flex.Item>
              <Button
                color={Set_Color(set_temperature, "blue", on)}
                disabled={!on}
                onClick={() => act('switch_off')}>
                {Glitch_Text(emagged, "Off", 1)}
              </Button>
              <Button
                color={"green"}
                disabled={on || cell === null}
                onClick={() => act('switch_on')}>
                {Glitch_Text(emagged, "On", 1)}
              </Button>
            </Flex.Item>
          </Flex>
        </LabeledList.Item>
        <LabeledList.Item
          label={Glitch_Text(emagged, "Cell Power", 1)}
          verticalAlign={"middle"}>
          <ProgressBar
            grow
            color={Set_Color(set_temperature, "green", on)}
            ranges={{
              "green": [0.5, Infinity],
              "yellow": [0.1, 0.5],
              "red": [-Infinity, 0.1],
            }}
            value={Math.max(0, [cell !== null ? cell_charge/100 : 0])}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const TemperatureRegulator = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    emagged,
    on,
    min,
    max,
    cell,
    cell_charge,
    set_temperature,
  } = data;
  return (
    <Section title={Glitch_Text(emagged, "Temperature regulator", 3)}>
      {!!on && !!emagged && !HVAC_Death(emagged, cell, cell_charge) && (
        <Modal
          backgroundColor={Set_Color(set_temperature, "#001414")}
          align="center"
          height={5.8}
          width={28.5} // This sucks
          mr={1.4}
        >
          {Generate_Emag_Text(Find_Theme(emagged, set_temperature, on), 5)}
        </Modal>
      )}
      <Stack justify="center" align="center">
        <Stack.Item>
          <Button
            icon={"fast-backward"}
            tooltip={"Set minimum"}
            disabled={set_temperature === min}
            onClick={() => act("set_temp", { inputted_temperature: min })} />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={"backward"}
            tooltip={emagged ? "Decrease by 50": "Decrease by 5"}
            disabled={set_temperature === min}
            onClick={() => act("set_temp", { temperature_adjust: emagged ? -50: -5 })} />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={"equals"}
            tooltip={"Room temperature"}
            onClick={() => act("set_temp", { inputted_temperature: 293 })} />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={"forward"}
            tooltip={emagged ? "Increase by 50": "Increase by 5"}
            disabled={set_temperature === max}
            onClick={() => act("set_temp", { temperature_adjust: emagged ? 50: 5 })} />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={"fast-forward"}
            tooltip={"Set maximum"}
            disabled={set_temperature === max}
            onClick={() => act("set_temp", { inputted_temperature: max })} />
        </Stack.Item>
      </Stack>
      <Divider />
      <Slider
        value={set_temperature}
        format={value => value+" K"}
        bold
        textColor={set_temperature >= 293 ? "red": "blue"}
        minValue={min}
        maxValue={max}
        step={emagged ? 5: 1}
        stepPixelSize={emagged ? 1.5: 4.5}
        ranges={{
          "blue": [-Infinity, 292],
          "red": [293, Infinity],
        }}
        onDrag={(e, value) => act("set_temp", { inputted_temperature: value })}
      />
    </Section>
  );
};
