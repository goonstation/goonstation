/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Chart, LabeledList, Stack, Table } from '../../components';
import { formatPower } from '../../format';
import { SortDirection } from '../PlayerPanel/constant';
import { Header } from '../PlayerPanel/Header';
import { numericCompare, PowerMonitorSmesData, PowerMonitorSmesItemData, SmesTableHeaderColumns, SmesTableHeaderColumnSortState } from './type';

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

interface PowerMonitorSemsTableHeaderProps {
  setSortBy: (field: SmesTableHeaderColumns) => any;
  state: SmesTableHeaderColumnSortState;
}

export const PowerMonitorSmesTableHeader = (props: PowerMonitorSemsTableHeaderProps) => {
  return (
    <>
      <Table.Cell header>
        <Header
          sortDirection={props.state?.field === SmesTableHeaderColumns.Area ? props.state.dir : null}
          onSortClick={() => props.setSortBy(SmesTableHeaderColumns.Area)} >
          Area
        </Header>
      </Table.Cell>
      <Table.Cell header>
        <Header
          sortDirection={props.state?.field === SmesTableHeaderColumns.StoredPower ? props.state.dir : null}
          onSortClick={() => props.setSortBy(SmesTableHeaderColumns.StoredPower)}>
          Stored Power#
        </Header>
      </Table.Cell>
      <Table.Cell header>
        <Header
          sortDirection={props.state?.field === SmesTableHeaderColumns.Charging ? props.state.dir : null}
          onSortClick={() => props.setSortBy(SmesTableHeaderColumns.Charging)} >
          Charging
        </Header>
      </Table.Cell>
      <Table.Cell header>
        <Header
          sortDirection={props.state?.field === SmesTableHeaderColumns.Input ? props.state.dir : null}
          onSortClick={() => props.setSortBy(SmesTableHeaderColumns.Input)}>
          Input
        </Header>
      </Table.Cell>
      <Table.Cell header>
        <Header
          sortDirection={props.state?.field === SmesTableHeaderColumns.Output ? props.state.dir : null}
          onSortClick={() => props.setSortBy(SmesTableHeaderColumns.Output)}>
          Output
        </Header>
      </Table.Cell>
      <Table.Cell header>
        <Header
          sortDirection={props.state?.field === SmesTableHeaderColumns.Active ? props.state.dir : null}
          onSortClick={() => props.setSortBy(SmesTableHeaderColumns.Active)}>
          Active
        </Header>
      </Table.Cell>
      <Table.Cell header>
        <Header
          sortDirection={props.state?.field === SmesTableHeaderColumns.Load ? props.state.dir : null}
          onSortClick={() => props.setSortBy(SmesTableHeaderColumns.Load)} >
          Load
        </Header>
      </Table.Cell>
    </>
  );
};

const smesDataComparer
  = (a: PowerMonitorSmesItemData,
    b: PowerMonitorSmesItemData,
    names: Record<string, string>,
    field: SmesTableHeaderColumns): number => {

    if (field === SmesTableHeaderColumns.Area) {
      return names[a[field]].localeCompare(names[b[field]]);
    } else if (field === SmesTableHeaderColumns.Charging || field === SmesTableHeaderColumns.Active) {
      if (a[field] === a[field]) {
        return 0;
      } else if (a[field] > b[field]) {
        return 1;
      } else {
        return -1;
      }
    } else {
      return numericCompare(a[field], (b[field]));
    }
  };

const sortSmesData
  = (data: PowerMonitorSmesItemData[],
    names: Record<string, string>,
    state: SmesTableHeaderColumnSortState): PowerMonitorSmesItemData[] => {

    if (state !== null) {
      data.sort((a, b) => smesDataComparer(a, b, names, state.field));
      if (state.dir === SortDirection.Asc) {
        data.reverse();
      }
    }


    return data;
  };

type PowerMonitorSmesTableRowsProps = {
  search: string;
  sortState: SmesTableHeaderColumnSortState;
};

export const PowerMonitorSmesTableRows = (props: PowerMonitorSmesTableRowsProps, context) => {
  const { search } = props;
  const { data } = useBackend<PowerMonitorSmesData>(context);


  return (
    <>
      {sortSmesData(data.units, data.unitNames, props.sortState).map((unit) => (
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
