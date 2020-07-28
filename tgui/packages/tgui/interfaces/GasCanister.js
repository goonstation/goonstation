import { useBackend } from '../backend';
import { Button, LabeledList, Section, NoticeBox, Box, Icon, ProgressBar, NumberInput, AnimatedNumber, LabeledControls, Flex } from '../components';
import { Window } from '../layouts';

export const GasCanister = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    release_pressure,
    current_pressure,
    maximum_pressure,
    has_valve,
    valve_open,
  } = data;
  return (
    <Window
      width={400}
      height={300}>
      <Window.Content>
        <Section title="Pressure">
          <PressureBar
            pressure={current_pressure}
            max_pressure={maximum_pressure} />
        </Section>
        <Section>
          <LabeledList>
            {!!has_valve && (
              <LabeledList.Item label="Release valve">
                <Button
                  content={valve_open ? 'Open' : 'Closed'}
                  onClick={() => act('toggle-valve')} />
              </LabeledList.Item>
            )}

            <LabeledList.Item label="Release pressure">
              <Button
                onClick={() => act('set-min-pressure')}>
                <Icon name="angle-double-left" size={1} mx={0} />
              </Button>
              <Box inline>
                <NumberInput
                  animated
                  width="85px"
                  value={release_pressure}
                  minValue={0}
                  onChange={(e, newValue) => act('set-pressure', {
                    release_pressure: newValue,
                  })} />
              </Box>
              <Button
                onClick={() => act('set-max-pressure')} >
                <Icon name="angle-double-right" size={1} mx={0} />
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

export const PressureBar = props => {
  const {
    pressure,
    max_pressure,
    ...rest
  } = props;
  const bgColorSafe = "black";
  const bgColorDanger = "red";
  const barColorSafe = "green";
  const barColorDanger = "yellow";

  const barColor = () => {
    if ((pressure / max_pressure) > 1) {
      return barColorDanger;
    } else {
      return barColorSafe;
    }
  };

  const bgColor = () => {
    if ((pressure / max_pressure) > 1) {
      return bgColorDanger;
    } else {
      return bgColorSafe;
    }
  };

  const pct = () => {
    if (pressure / max_pressure > 1) {
      return pressure / (max_pressure * 10);
    } else {
      return pressure / max_pressure;
    }
  };

  return (
    <Box danger p={0.4} backgroundColor={bgColor()}>
      <ProgressBar color={barColor()} value={pct()}>
        <AnimatedNumber
          value={pressure}
          format={value => (Math.floor(value * 100) / 100) + " kPa"}
        />
      </ProgressBar>
    </Box>
  );
};
