import { useBackend } from '../backend';
import { Button, Knob, Box, Section, Table, RoundGauge } from '../components';
import { Window } from '../layouts';
import { Flex } from '../components';
import { capitalize } from './common/stringUtils';
import { getTemperatureColor } from './common/temperatureUtils';
import { round } from 'common/math';
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
          const { x, y, name, img, temp, extra, flux } = c;
          return (
            <Table.Cell>
              <Button
                key={name}
                fluid
                tooltip={<>{capitalize(name)}<br />{round(temp-T0C, 2)} °C{extra !== "" ? <><br />{extra}</> : ""}{flux !== null ? <><br />{flux} Neutrons</> : ""}</>}
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
    configuredControlRodLevel,
    actualControlRodLevel,
  } = data;
  return (
    <Window
      resizable
      title="Nuclear Reactor"
      width={500}
      height={700}>
      <Window.Content>
        <Section>
          <ReactorGrid
            gridW={gridW}
            gridH={gridH}
            onClick={act}
            components={components}
            emptySlotIcon={emptySlotIcon}
          />
        </Section>
        <Section>
          <Flex justify="space-between" align="center">
            <Flex.Item>
              <Box>Reactor Temperature:</Box>
              <RoundGauge
                minValue={0-T0C}
                maxValue={1500}
                size={5}
                value={reactorTemp}
                format={value => round(value-T0C, 2)+ " °C"}
                alertAfter={1200}
                ranges={{
                  "good": [0-T0C, 1000],
                  "average": [1000, 1200],
                  "bad": [1200, 1500],
                }} />
            </Flex.Item>
            <Flex.Item>
              <Box>Radiation Level:</Box>
              <RoundGauge
                minValue={0}
                maxValue={100}
                size={5}
                value={reactorRads}
                format={value => round(value, 1) + " clicks"}
                alertAfter={50}
                ranges={{
                  "good": [0, 10],
                  "average": [10, 50],
                  "bad": [50, 100],
                }} />
            </Flex.Item>
          </Flex>
        </Section>
        <Section>
          <Flex justify="space-between" align="center">
            <Flex.Item>
              <Box>Control Rod Insertion:</Box>
              <RoundGauge
                minValue={-100}
                maxValue={0}
                size={5}
                value={-actualControlRodLevel}
                format={value => round(-value, 1)+"%"}
                alertAfter={-5}
                ranges={{
                  "good": [-100, -30],
                  "average": [-30, -10],
                  "bad": [-10, 0],
                }} />
            </Flex.Item>
            <Flex.Item>
              <Button color="transparent" icon="angle-double-left" onClick={() => act('adjustCR', { crvalue: 0 })} />
              <Button color="transparent" icon="angle-left" onClick={() => act('adjustCR', { crvalue: configuredControlRodLevel-5 })} />
              {configuredControlRodLevel} %
              <Button color="transparent" icon="angle-right" onClick={() => act('adjustCR', { crvalue: configuredControlRodLevel-5 })} />
              <Button color="transparent" icon="angle-double-right" onClick={() => act('adjustCR', { crvalue: 100 })} />
              <Knob
                animated
                size={3}
                value={configuredControlRodLevel}
                minValue={0}
                maxValue={100}
                format={value => value + "%"}
                onDrag={(e, value) => act('adjustCR', { crvalue: value })}
              />
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
