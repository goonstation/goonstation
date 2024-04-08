/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Box, Chart, LabeledList, Stack, Table } from '../../components';
import { formatPower } from '../../format';
import { SortableTableRowProps } from '../common/sorting';
import { PowerMonitorApcData, PowerMonitorApcItemData } from './type';

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

export const getRowDataForApcs = (
  data: PowerMonitorApcItemData[],
  lut: Record<string, string>): SortableTableRowProps[] => {

  let array = Array<SortableTableRowProps>();
  for (let idx = 0; idx < data.length; idx++) {
    const apc = data[idx];
    const [ref, equipment, lighting, environment, load, cellCharge, cellCharging] = apc;
    const name = lut[ref];
    array.push({
      cells: [{
        data: name,
        children: name,
      }, {
        data: equipment,
        children: <ApcState state={equipment} />,
        wrapInCell: false,
      }, {
        data: lighting,
        children: <ApcState state={lighting} />,
        wrapInCell: false,
      }, {
        data: environment,
        children: <ApcState state={environment} />,
        wrapInCell: false,
      }, {
        data: load,
        children: formatPower(load),
        textAlign: "right",
        nowrap: true,
      }, {
        data: cellCharge,
        wrapInCell: false,
        children: <CellCharge cellCharge={cellCharge} cellCharging={cellCharging} />,
      }, {
        data: cellCharging,
        wrapInCell: false,
        children: null,
      }],
    });
  }
  return array;
};

interface CellChargeProps {
  cellCharge: number,
  cellCharging: number
}
const CellCharge = (props: CellChargeProps) => {
  const { cellCharge, cellCharging } = props;

  return typeof cellCharge === 'number' ? (

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
    </>);
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
