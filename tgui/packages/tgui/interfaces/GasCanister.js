import { useBackend } from '../backend';
import { Button, LabeledList, Section, Box, ProgressBar, NumberInput, AnimatedNumber, LabeledControls } from '../components';
import { Window } from '../layouts';

export const GasCanister = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    release_pressure,
    current_pressure,
    has_valve,
    valve_open,
  } = data;
  return (
    <Window
      width={600}
      height={300}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Release pressure">
              {release_pressure}
            </LabeledList.Item>
            <LabeledList.Item label="Button">
              <Button
                content="Dispatch a 'test' action"
                onClick={() => act('test')} />
            </LabeledList.Item>
          </LabeledList>
          <AnimatedNumber
            value={current_pressure}
            format={value => value + " kPa"}
          />
          <LabeledControls>
            <LabeledControls.Item label="Release valve">
              <Button
                content={valve_open ? 'Open' : 'Closed'}
                onClick={() => act('toggle-valve')} />
            </LabeledControls.Item>
            <LabeledControls.Item label="Release pressure">
              <Button
                content="Min"
              />
              <NumberInput
                animated
                value={release_pressure}
                minValue={0}
                suppressFlicker={2000}
                onChange={(e, value) => act('set-pressure', {
                  release_pressure: value,
                })}
              />
              <Button
                content="Max"
              />
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
      </Window.Content>
    </Window>
  );
};

const PressureBar = (pressure, max_pressure, width = 300) => {
  let pct = pressure / max_pressure;
  const bgColor = "#000000";
  const bgColorDanger = "#b00000";
  const barColor = "#00cc00";
  const barColorDanger = "#ffff00";

  return (
    <Box backgroundColor="#000000" width={"300px"} height={"1.5em"}>
      Hello
    </Box>
  );
};
