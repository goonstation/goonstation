import { useBackend } from "../backend";
import { AnimatedNumber, Box, Button, Dimmer, Flex, Icon, Knob, Section, Stack } from '../components';
import { Window } from '../layouts';
import { Color } from 'common/color';
import { NoContainer, ReagentGraph, ReagentList } from './common/ReagentInfo.js';

const TemperatureColors = {
  cold: new Color(66, 194, 255),
  neutral: new Color(170, 170, 170),
  hot: new Color(255, 120, 0),
  veryhot: new Color(255, 0, 0),
};

const neutralTemperature = 293.15;
const deviation = 200;
const highTemperature = neutralTemperature + deviation;

const getTemperatureColor = (temperature) => {
  const { cold, neutral, hot, veryhot } = TemperatureColors;

  if (temperature < highTemperature) {
    return Color.lookup((temperature - neutralTemperature) / (deviation * 2) + 0.5, [cold, neutral, hot]);
  }
  return Color.lookup((temperature - highTemperature) / (1000 - highTemperature), [hot, veryhot]);
};

const getTemperatureIcon = (temperature) => {
  switch (Math.round(temperature/200)) {
    case (0): return "thermometer-empty";
    case (1): return "thermometer-quarter";
    case (2): return "thermometer-half";
    case (3): return "thermometer-three-quarters";
    default: return "thermometer-full";
  }
};

const getTemperatureChange = (temperature, targetTemperature) => {
  if (temperature < targetTemperature) return "heating";
  if (temperature > targetTemperature) return "cooling";
  return "neutral";
};

export const ChemHeater = (props, context) => {
  const { act, data } = useBackend(context);
  const { containerData, isActive, targetTemperature } = data;

  return (
    <Window
      title="Reagent Heater/Cooler"
      width={320}
      height={385}>
      <Window.Content>
        <ChemDisplay container={containerData} targetTemperature={targetTemperature} active={isActive} />
        <Section title="Temperature Control">

          <Stack align="center">
            <Stack.Item>
              <Knob
                animated
                size={2}
                value={targetTemperature}
                minValue={0}
                maxValue={1000}
                onDrag={(e, value) => act('adjustTemp', { temperature: value })}
              />
            </Stack.Item>
            <Stack.Item grow overflow="hidden" py={1}>
              <Box
                className="TemperatureNumber"
                nowrap
                p={1}
                fontSize={1.5}
                color={getTemperatureColor(targetTemperature)}
                backgroundColor="black">
                <Box fontSize={1}>Target</Box>
                <Icon name={getTemperatureIcon(targetTemperature)} pr={0.5} />
                <AnimatedNumber value={targetTemperature} /> K
              </Box>
            </Stack.Item>
            <Stack.Item basis={9.6} align="center">
              <Button
                icon="power-off"
                disabled={!(containerData && containerData.totalVolume)}
                color={isActive ? "red" : "green"}
                fluid
                height="100%"
                fontSize={1.25}
                textAlign="center"
                onClick={() => act(isActive ? 'stop' : 'start')}>
                {isActive ? "Deactivate" : "Activate"}
              </Button>
            </Stack.Item>
          </Stack>

        </Section>
      </Window.Content>
    </Window>
  );
};

const ChemDisplay = (props, context) => {
  const { act } = useBackend(context);
  const { active = true, targetTemperature } = props;
  const container = props.container || NoContainer;
  const working = active && !container.fake;
  const { temperature, totalVolume } = container;

  return (
    <Section
      title={
        <Flex inline nowrap>
          <Flex.Item grow
            overflow="hidden"
            style={{
              "text-overflow": "ellipsis",
              "text-transform": "capitalize",
            }}>
            {container.name}
          </Flex.Item>
          <Flex.Item px={4.25} /> {/* button overlap prevention */}
        </Flex>
      }
      buttons={
        <Button
          icon="eject"
          disabled={!props.container}
          onClick={() => act('eject')}>
          Eject
        </Button>
      }>
      <ReagentGraph container={container} />
      <ReagentList container={container} />
      <Box className={"TemperatureBox " + (working && `TemperatureBox__${getTemperatureChange(temperature, targetTemperature)}`)}>
        {!totalVolume || (
          <Box
            fontSize={2}
            color={getTemperatureColor(temperature)}
            className={"TemperatureNumber"}>
            <Icon name="long-arrow-alt-down"
              className={"TemperatureArrow " + (working && `TemperatureArrow__${getTemperatureChange(temperature, targetTemperature)}`)}
              pt="2px"
              pr={0.25}
              style={{
                transform: active ? `scaleY(${Math.sign(temperature - targetTemperature)})` : "scaleY(0)",
              }}
            />
            <Icon name={getTemperatureIcon(temperature)} pr={0.5} />
            <AnimatedNumber value={temperature} /> K
          </Box>
        )}
      </Box>
      {!!props.container || (
        <Dimmer>
          <Button
            icon="eject"
            fontSize={1.5}
            onClick={() => act('insert')}
            bold>
            Insert Beaker
          </Button>
        </Dimmer>
      )}
    </Section>
  );
};
