/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Chart, LabeledList, Stack, Table } from '../../components';
import { formatPower } from '../../format';
import { Header } from '../common/sorting/Header';
import { PowerMonitorHeaderTableHeaderProps, PowerMonitorSmesData, PowerMonitorSmesItemData, SingleSortState, SmesTableHeaderColumns } from './type';
import { SortPowerMonitorData } from './utils';

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
const PowerMonitorSmesTableHeader = (props: PowerMonitorHeaderTableHeaderProps<SmesTableHeaderColumns>) => {
  return (
    <>
      <Table.Cell header>
        <Header
          sortDirection={props.sortState?.field === SmesTableHeaderColumns.Area ? props.sortState.dir : null}
          onSortClick={() => props.setSortBy(SmesTableHeaderColumns.Area)} >
          Area
        </Header>
      </Table.Cell>
      <Table.Cell header>
        <Header
          sortDirection={props.sortState?.field === SmesTableHeaderColumns.StoredPower ? props.sortState.dir : null}
          onSortClick={() => props.setSortBy(SmesTableHeaderColumns.StoredPower)}>
          Stored Power#
        </Header>
      </Table.Cell>
      <Table.Cell header>
        <Header
          sortDirection={props.sortState?.field === SmesTableHeaderColumns.Charging ? props.sortState.dir : null}
          onSortClick={() => props.setSortBy(SmesTableHeaderColumns.Charging)} >
          Charging
        </Header>
      </Table.Cell>
      <Table.Cell header>
        <Header
          sortDirection={props.sortState?.field === SmesTableHeaderColumns.Input ? props.sortState.dir : null}
          onSortClick={() => props.setSortBy(SmesTableHeaderColumns.Input)}>
          Input
        </Header>
      </Table.Cell>
      <Table.Cell header>
        <Header
          sortDirection={props.sortState?.field === SmesTableHeaderColumns.Output ? props.sortState.dir : null}
          onSortClick={() => props.setSortBy(SmesTableHeaderColumns.Output)}>
          Output
        </Header>
      </Table.Cell>
      <Table.Cell header>
        <Header
          sortDirection={props.sortState?.field === SmesTableHeaderColumns.Active ? props.sortState.dir : null}
          onSortClick={() => props.setSortBy(SmesTableHeaderColumns.Active)}>
          Active
        </Header>
      </Table.Cell>
      <Table.Cell header>
        <Header
          sortDirection={props.sortState?.field === SmesTableHeaderColumns.Load ? props.sortState.dir : null}
          onSortClick={() => props.setSortBy(SmesTableHeaderColumns.Load)} >
          Load
        </Header>
      </Table.Cell>
    </>
  );
};

type PowerMonitorSmesTableRowsProps = {
  search: string;
  sortState: SingleSortState<SmesTableHeaderColumns>;
};

const PowerMonitorSmesTableRows = (props: PowerMonitorSmesTableRowsProps, context) => {
  const { search } = props;
  const { data } = useBackend<PowerMonitorSmesData>(context);


  return (
    <>
      {SortPowerMonitorData(data.units, data.unitNames, props.sortState).map((unit) => (
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


interface SmesPowerMonitorProps {
  setSortBy: (field: SmesTableHeaderColumns) => void;
  sortState: SingleSortState<SmesTableHeaderColumns>,
  search: string,
}
export const SmesPowerMonitor = (props: SmesPowerMonitorProps) => {
  const { setSortBy, sortState, search } = props;
  return (
    <>
      <PowerMonitorSmesTableHeader sortState={sortState} setSortBy={setSortBy} />
      <PowerMonitorSmesTableRows search={search} sortState={sortState} />
    </>
  );
};
