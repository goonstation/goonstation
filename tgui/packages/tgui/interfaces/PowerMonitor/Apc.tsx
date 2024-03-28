/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Box, Chart, LabeledList, Stack, Table, Tooltip } from '../../components';
import { formatPower } from '../../format';
import { SortDirection } from '../common/sorting/constant';
import { Header } from '../common/sorting/Header';
import { ApcTableHeaderColumns, ApcTableHeaderColumnSortState, numericCompare, PowerMonitorApcData, PowerMonitorApcItemData } from './type';

const apcState = {
  [0]: 'Off',
  [1]: (
    <Box inline>
      Off{' '}
      <Box inline color="grey">
        (Auto)
      </Box>
    </Box>
  ),
  [2]: 'On',
  [3]: (
    <Box inline>
      On{' '}
      <Box inline color="grey">
        (Auto)
      </Box>
    </Box>
  ),
};

const apcCellState = {
  [0]: 'Discharging',
  [1]: 'Charging',
  [2]: 'Charged',
};

export const PowerMonitorApcGlobal = (_props, context) => {
  const { data } = useBackend<PowerMonitorApcData>(context);

  const availableHistory = data.history.map((v) => v[0]);
  const availableHistoryData = availableHistory.map((v, i) => [i, v]);

  const loadHistory = data.history.map((v) => v[1]);
  const loadHistoryData = loadHistory.map((v, i) => [i, v]);

  const max = Math.max(...availableHistory, ...loadHistory);

  return (
    <Stack fill>
      <Stack.Item width="50%">
        <LabeledList>
          <LabeledList.Item label="Total Power">{formatPower(data.available)}</LabeledList.Item>
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
          <LabeledList.Item label="Total Load">{formatPower(data.load)}</LabeledList.Item>
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
interface PowerMonitorApcTableHeaderProps {
  setSortBy: (type: ApcTableHeaderColumns) => any,
  state: ApcTableHeaderColumnSortState
}
export const PowerMonitorApcTableHeader = (props: PowerMonitorApcTableHeaderProps) => {
  return (
    <>
      <Table.Cell header>
        <Header
          sortDirection={props.state?.field === ApcTableHeaderColumns.Area ? props.state.dir : null}
          onSortClick={() => props.setSortBy(ApcTableHeaderColumns.Area)}>
          Area
        </Header>
      </Table.Cell>
      <Tooltip content="Equipment">
        <Table.Cell header collapsing>
          <Header
            sortDirection={props.state?.field === ApcTableHeaderColumns.Equipment ? props.state.dir : null}
            onSortClick={() => props.setSortBy(ApcTableHeaderColumns.Equipment)}>
            Eqp.
          </Header>
        </Table.Cell>
      </Tooltip>
      <Tooltip content="Lighting">
        <Table.Cell header collapsing>
          <Header
            sortDirection={props.state?.field === ApcTableHeaderColumns.Lighting ? props.state.dir : null}
            onSortClick={() => props.setSortBy(ApcTableHeaderColumns.Lighting)}>
            Lgt.
          </Header>
        </Table.Cell>
      </Tooltip>
      <Tooltip content="Environment">
        <Table.Cell header collapsing>
          <Header
            sortDirection={props.state?.field === ApcTableHeaderColumns.Environment ? props.state.dir : null}
            onSortClick={() => props.setSortBy(ApcTableHeaderColumns.Environment)}>
            Env.
          </Header>
        </Table.Cell>
      </Tooltip>
      <Table.Cell header textAlign="right">
        <Header
          sortDirection={props.state?.field === ApcTableHeaderColumns.Load ? props.state.dir : null}
          onSortClick={() => props.setSortBy(ApcTableHeaderColumns.Load)}>
          Load
        </Header>
      </Table.Cell>
      <Table.Cell header textAlign="right">
        <Header
          sortDirection={props.state?.field === ApcTableHeaderColumns.CellCharge ? props.state.dir : null}
          onSortClick={() => props.setSortBy(ApcTableHeaderColumns.CellCharge)}>
          Cell Charge
        </Header>
      </Table.Cell>
      <Table.Cell header>
        <Header
          sortDirection={props.state?.field === ApcTableHeaderColumns.CellState ? props.state.dir : null}
          onSortClick={() => props.setSortBy(ApcTableHeaderColumns.CellState)}>
          Cell State
        </Header>
      </Table.Cell>
    </>
  );
};

const apcDataComparer
  = (a: PowerMonitorApcItemData,
    b: PowerMonitorApcItemData,
    names: Record<string, string>,
    field: ApcTableHeaderColumns): number => {

    if (field === ApcTableHeaderColumns.Area) {
      return names[a[field]].localeCompare(names[b[field]]);
    } else {
      return numericCompare(a[field], (b[field]));
    }
  };

const sortApcData
  = (data: PowerMonitorApcItemData[],
    names: Record<string, string>,
    state: ApcTableHeaderColumnSortState): PowerMonitorApcItemData[] => {

    if (state !== null) {
      data.sort((a, b) => apcDataComparer(a, b, names, state.field));
      if (state.dir === SortDirection.Asc) {
        data.reverse();
      }
    }


    return data;
  };

type PowerMonitorApcTableRowsProps = {
  search: string;
  sortState: ApcTableHeaderColumnSortState;
};
export const PowerMonitorApcTableRows = (props: PowerMonitorApcTableRowsProps, context) => {
  const { search } = props;
  const { data } = useBackend<PowerMonitorApcData>(context);

  return (
    <>
      {sortApcData(data.apcs, data.apcNames, props.sortState).map((apc) => (
        <PowerMonitorApcTableRow key={apc[0]} apc={apc} search={search} />
      ))}
    </>
  );
};

type PowerMonitorApcTableRowProps = {
  apc: PowerMonitorApcItemData;
  search: string;
};

const PowerMonitorApcTableRow = (props: PowerMonitorApcTableRowProps, context) => {
  const { apc, search } = props;
  // Indexed array to lower data transfer between byond and the window.
  const [ref, equipment, lighting, environment, load, cellCharge, cellCharging] = apc;
  const { data } = useBackend<PowerMonitorApcData>(context);
  const name = data.apcNames[ref] ?? 'N/A';

  if (search && !name.toLowerCase().includes(search.toLowerCase())) {
    return null;
  }

  return (
    <Table.Row>
      <Table.Cell>{name}</Table.Cell>
      <ApcState state={equipment} />
      <ApcState state={lighting} />
      <ApcState state={environment} />
      <Table.Cell textAlign="right" nowrap>
        {formatPower(load)}
      </Table.Cell>
      {typeof cellCharge === 'number' ? (
        <>
          <Table.Cell textAlign="right" nowrap>
            {cellCharge}%
          </Table.Cell>
          <Table.Cell color={cellCharging > 0 ? (cellCharging === 1 ? 'average' : 'good') : 'bad'} nowrap>
            {apcCellState[cellCharging]}
          </Table.Cell>
        </>
      ) : (
        <>
          <Table.Cell />
          <Table.Cell color="bad">N/A</Table.Cell>
        </>
      )}
    </Table.Row>
  );
};

type ApcStateProps = {
  state: number;
};

const ApcState = ({ state }: ApcStateProps) => {
  return (
    <Table.Cell nowrap color={state >= 2 ? 'good' : 'bad'}>
      {apcState[state]}
    </Table.Cell>
  );
};
