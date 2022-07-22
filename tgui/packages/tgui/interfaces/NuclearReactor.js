import { useBackend } from '../backend';
import { BlockQuote, Button, Knob, Box, Section, Table, RoundGauge } from '../components';
import { Window } from '../layouts';
import { useLocalState } from '../backend';
import { Divider, Flex, Stack } from '../components';
import { capitalize, pluralize } from './common/stringUtils';
import { freezeTemperature, getTemperatureColor, getTemperatureIcon, getTemperatureChangeName } from './common/temperatureUtils';
import { clamp, round, toFixed } from 'common/math';
const T0C = 273.15;

const ReactorRow = (shape) => {
  const {
    onClick,
    components,
    rowID,
    emptySlotIcon,
  } = shape;
  return (
    <Table.Row>
      {components.map((c, index) => {
        if (c === null)
        {
          return (
            <Table.Cell>
              <Button
                key={name}
                fluid
                color="transparent"
                m={1}
                onClick={() => onClick('slot', { "x": rowID+1, "y": index+1 })} >
                <img
                  src={`data:image/png;base64,${emptySlotIcon}`}
                  style={{
                    'vertical-align': 'middle',
                    'border-color': '#AAAAAA',
                    'border-style': 'solid',
                    'border-radius': '4px',
                    'horizontal-align': 'middle',
                  }}
                />
              </Button>
            </Table.Cell>
          );
        }
        else
        {
          const { x, y, name, img, temp, extra } = c;
          return (
            <Table.Cell>
              <Button
                key={name}
                fluid
                tooltip={<>{capitalize(name)}<br />{round(temp-T0C, 2)} °C<br />{extra}</>}
                color="transparent"
                m={1}
                onClick={() => onClick('slot', { "x": x, "y": y })} >
                <img
                  src={`data:image/png;base64,${img}`}
                  style={{
                    'box-shadow': `0px 0px 20px ${getTemperatureColor(temp, 2000)}`,
                    'vertical-align': 'middle',
                    'border-color': `${getTemperatureColor(temp, 2000)}`,
                    'border-style': 'solid',
                    'border-radius': '4px',
                    'horizontal-align': 'middle',
                  }}
                />
              </Button>
            </Table.Cell>);
        }
      })}
    </Table.Row>
  );
};

const ReactorGrid = (shape) => {
  const {
    onClick,
    components,
    emptySlotIcon,
  } = shape;
  return (
    <Table>
      {components.map((r, index) => { const { comp } = r;
        return (
          <Table.Row key>
            <ReactorRow rowID={index} components={r} onClick={onClick} emptySlotIcon={emptySlotIcon} />
          </Table.Row>
        );
      })}
    </Table>
  );
};



export const NuclearReactor = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    gridW,
    gridH,
    emptySlotIcon,
    components,
    reactorTemp,
    reactorRads,
    controlRodLevel,
  } = data;
  return (
    <Window
      resizable
      title="Nuclear Reactor"
      width={(gridW+1)*64}
      height={650}>
      <Window.Content>
        <Section>
          <Box>
            <ReactorGrid
              gridW={gridW}
              gridH={gridH}
              onClick={act}
              components={components}
              emptySlotIcon={emptySlotIcon}
            />
          </Box>
        </Section>
        <Section>
          <Box>
            <Stack fill>
              <Stack.Item width="50%">
                Reactor Temperature:
                <RoundGauge
                  minValue={0-T0C}
                  maxValue={2500-T0C}
                  size={5}
                  value={reactorTemp}
                  format={value => round(value-T0C, 2)+ " °C"}
                  alertAfter={2000-T0C}
                  ranges={{
                    "good": [0-T0C, 1000-T0C],
                    "average": [1000-T0C, 2000-T0C],
                    "bad": [2000-T0C, 2500-T0C],
                  }} />
              </Stack.Item>
              <Stack.Item width="50%">
                Radiation Level:
                <RoundGauge
                  minValue={0}
                  maxValue={200}
                  size={5}
                  value={reactorRads}
                  format={value => round(value, 1) + " clicks"}
                  alertAfter={50}
                  ranges={{
                    "good": [0, 10],
                    "average": [10, 75],
                    "bad": [75, 200],
                  }} />
              </Stack.Item>
            </Stack>
          </Box>
          <Box>
            <Stack fill>
              <Stack.Item width="50%">
                Control Rod Insertion: {controlRodLevel}%
              </Stack.Item>
              <Stack.Item width="50%">
                <Knob
                  animated
                  size={2}
                  value={controlRodLevel}
                  minValue={0}
                  maxValue={100}
                  format={value => value + "%"}
                  onDrag={(e, value) => act('adjustCR', { crvalue: value })}
                />
              </Stack.Item>
            </Stack>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
