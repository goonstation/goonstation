/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Chart, LabeledList, Stack, Table } from '../../components';
import { formatPower } from '../../format';
import { PowerMonitorSmesData, PowerMonitorSmesItemData } from './type';

export const PowerMonitorSmesGlobal = (_props, context) => {
  const { data } = useBackend<PowerMonitorSmesData>(context);

  const availableHistory = data.history.map((v) => v[0]);
  const availableHistoryData = availableHistory.map((v, i) => [i, v]);

  const loadHistory = data.history.map((v) => v[1]);
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

type PowerMonitorSmesTableRowsProps = {
  search: string;
};

export const PowerMonitorSmesTableRows = (props: PowerMonitorSmesTableRowsProps, context) => {
  const { search } = props;
  const { data } = useBackend<PowerMonitorSmesData>(context);

  return (
    <>
      {data.units.map((unit) => (
        <PowerMonitorSmesTableRow key={unit[0]} unit={unit} search={search} />
      ))}
    </>
  );
};

type PowerMonitorSmesTableRowProps = {
  unit: PowerMonitorSmesItemData;
  search: string;
};

const PowerMonitorSmesTableRow = (props: PowerMonitorSmesTableRowProps, context) => {
  const { unit, search } = props;
  // Indexed array to lower data transfer between byond and the window.
  const [ref, stored, charging, input, output, online, load] = unit;
  const { data } = useBackend<PowerMonitorSmesData>(context);
  const name = data.unitNames[ref] ?? 'N/A';

  if (search && !name.toLowerCase().includes(search.toLowerCase())) {
    return null;
  }

  return (
    <Table.Row>
      <Table.Cell>{name}</Table.Cell>
      <Table.Cell>{stored}%</Table.Cell>
      <Table.Cell color={charging ? 'good' : 'bad'}>{charging ? 'Yes' : 'No'}</Table.Cell>
      <Table.Cell>{formatPower(input)}</Table.Cell>
      <Table.Cell>{formatPower(output)}</Table.Cell>
      <Table.Cell color={online ? 'good' : 'bad'}>{online ? 'Yes' : 'No'}</Table.Cell>
      <Table.Cell>{load ? formatPower(load) : 'N/A'}</Table.Cell>
    </Table.Row>
  );
};
