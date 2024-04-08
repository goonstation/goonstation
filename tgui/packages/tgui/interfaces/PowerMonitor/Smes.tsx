/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Chart, LabeledList, Stack } from '../../components';
import { formatPower } from '../../format';
import { SortableTableRowProps } from '../common/sorting';

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

export const getRowDataForSmes = (
  data: PowerMonitorSmesItemData[],
  lut: Record<string, string>): SortableTableRowProps[] => {

  let array = Array<SortableTableRowProps>();
  for (let idx = 0; idx < data.length; idx++) {
    const unit = data[idx];
    const [ref, stored, charging, input, output, online, load] = unit;
    const name = lut[ref];
    array.push({
      cells: [{
        data: name,
        children: name,
      }, {
        data: stored,
        children: `${stored}%`,
      }, {

        data: charging,
        children: charging ? 'Yes' : 'No',
        color: charging ? 'good' : 'bad',
      }, {
        data: input,
        children: formatPower(input),
      }, {
        data: load,
        children: formatPower(output),

      }, {
        data: online,
        color: online ? 'good' : 'bad',
        children: online ? 'Yes' : 'No',
      }, {
        data: load,
        children: load ? formatPower(load) : 'N/A',
      }],
    });
  }
  return array;
};
