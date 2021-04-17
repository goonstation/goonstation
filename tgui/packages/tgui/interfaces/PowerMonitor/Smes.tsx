import { useBackend, useSharedState } from '../../backend';
import { Box, Chart, LabeledList, Stack, Table } from '../../components';
import { formatPower } from '../../format';
import { PowerMonitorSmesData, PowerMonitorSmesItemData } from './type';

export const PowerMonitorSmesGlobal = (_props, context) => {
  const { data } = useBackend<PowerMonitorSmesData>(context);

  const availableHistory = data.history.map((v) => v.available);
  const availableHistoryData = availableHistory.map((v, i) => [i, v]);

  const loadHistory = data.history.map((v) => v.load);
  const loadHistoryData = loadHistory.map((v, i) => [i, v]);

  const max = Math.max(...availableHistory, ...loadHistory);

  return (
    <Stack fill>
      <Stack.Item width="50%">
        <LabeledList>
          <LabeledList.Item label="Engine Output">{formatPower(data.available)}</LabeledList.Item>
        </LabeledList>
        <Chart.Line
          mt="5px"
          height="5em"
          data={availableHistoryData}
          rangeX={[0, availableHistoryData.length - 1]}
          rangeY={[0, max]}
          strokeColor="rgba(1, 184, 170, 1)"
          fillColor="rgba(1, 184, 170, 0.25)"
        />
      </Stack.Item>
      <Stack.Item width="50%">
        <LabeledList>
          <LabeledList.Item label="SMES/PTL Draw">{formatPower(data.load)}</LabeledList.Item>
        </LabeledList>
        <Chart.Line
          mt="5px"
          height="5em"
          data={loadHistoryData}
          rangeX={[0, loadHistoryData.length - 1]}
          rangeY={[0, max]}
          strokeColor="rgba(1, 184, 170, 1)"
          fillColor="rgba(1, 184, 170, 0.25)"
        />
      </Stack.Item>
    </Stack>
  );


};

export const PowerMonitorSmesTableHeader = (props, context) => {
  return (
    <>
      <Table.Cell header>Area</Table.Cell>
      <Table.Cell header>Stored Power</Table.Cell>
      <Table.Cell header>Charging</Table.Cell>
      <Table.Cell header>Input</Table.Cell>
      <Table.Cell header>Output</Table.Cell>
      <Table.Cell header>Active</Table.Cell>
      <Table.Cell header>Load</Table.Cell>
    </>
  );
};

export const PowerMonitorSmesTableRows = (props, context) => {
  const { data } = useBackend<PowerMonitorSmesData>(context);

  return (
    <>
      {data.units.map((unit) => (
        <PowerMonitorSmesTableRow key={unit.ref} unit={unit} />
      ))}
    </>
  );
};

type PowerMonitorSmesTableRowProps = {
  unit: PowerMonitorSmesItemData;
};

const PowerMonitorSmesTableRow = ({ unit }: PowerMonitorSmesTableRowProps, context) => {
  const { data } = useBackend<PowerMonitorSmesData>(context);
  const [search] = useSharedState(context, 'search', '');
  const { name = 'N/A' } = data.unitsStatic[unit.ref] ?? {};

  if (search && !name.toLowerCase().includes(search.toLowerCase())) {
    return null;
  }

  return (
    <Table.Row>
      <Table.Cell>{name}</Table.Cell>
      <Table.Cell>{unit.stored}%</Table.Cell>
      <Table.Cell color={unit.charging ? 'good' : 'bad'}>{unit.charging ? 'Yes' : 'No'}</Table.Cell>
      <Table.Cell>{formatPower(unit.input)}</Table.Cell>
      <Table.Cell>{formatPower(unit.output)}</Table.Cell>
      <Table.Cell color={unit.online ? 'good' : 'bad'}>{unit.online ? 'Yes' : 'No'}</Table.Cell>
      <Table.Cell>{unit.load ? formatPower(unit.load) : 'N/A'}</Table.Cell>
    </Table.Row>
  );
};
