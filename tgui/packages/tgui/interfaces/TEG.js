/**
 * @file
 * @copyright 2020
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Box, Chart, LabeledList, Section, Divider } from '../components';
import { formatPower, formatSiUnit } from '../format';
import { Window } from '../layouts';

export const TEG = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    output,
    history,
    hotCircStatus,
    hotInletTemp,
    hotOutletTemp,
    hotInletPres,
    hotOutletPres,
    coldCircStatus,
    coldInletTemp,
    coldOutletTemp,
    coldInletPres,
    coldOutletPres,
  } = data;
  const historyData = history.map((value, i) => [i, value]);
  const historyMax = Math.max(...history);
  return (
    <Window
      height="520"
      width="300" >
      <Window.Content>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Output History" />
          </LabeledList>
          <Chart.Line
            height="5em"
            data={historyData}
            rangeX={[0, historyData.length - 1]}
            rangeY={[0, historyMax]}
            strokeColor="rgba(1, 184, 170, 1)"
            fillColor="rgba(1, 184, 170, 0.25)" />
          <Divider />
          <LabeledList>
            <LabeledList.Item
              label="Energy Output"
              textAlign="right" >
              {formatPower(output)}
            </LabeledList.Item>
            <LabeledList.Item
              label="Hot Gas Circulator"
              textAlign="right" >
              <Box color={(hotCircStatus && hotInletTemp && 'good')
                  || (hotCircStatus && 'average')
                  || 'bad'} >
                {(hotCircStatus && hotInletTemp && 'OK')
                  || (hotCircStatus && 'Idle')
                  || 'ERROR'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item
              label="Cold Gas Circulator"
              textAlign="right" >
              <Box color={(coldCircStatus && coldInletTemp && 'good')
                  || (coldCircStatus && 'average')
                  || 'bad'} >
                {(coldCircStatus && coldInletTemp && 'OK')
                  || (coldCircStatus && 'Idle')
                  || 'ERROR'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Hot Loop">
          <LabeledList>
            <LabeledList.Item
              label="Inlet Temp"
              textAlign="right" >
              {(hotInletTemp >= 1000 && hotInletTemp.toExponential(3) + ' K')
                || hotInletTemp + ' K'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Outlet Temp"
              textAlign="right" >
              {(hotOutletTemp >= 1000 && hotOutletTemp.toExponential(3) + ' K')
                || hotOutletTemp + ' K'}
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item
              label="Inlet Pressure"
              textAlign="right" >
              {formatSiUnit(Math.max(hotInletPres, 0), 1, 'Pa')}
            </LabeledList.Item>
            <LabeledList.Item
              label="Outlet Pressure"
              textAlign="right" >
              {formatSiUnit(hotOutletPres, 1, 'Pa')}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Cold Loop">
          <LabeledList>
            <LabeledList.Item
              label="Inlet Temp"
              textAlign="right" >
              {(coldInletTemp >= 1000 && coldInletTemp.toExponential(3) + ' K')
                || coldInletTemp + ' K'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Outlet Temp"
              textAlign="right" >
              {(coldOutletTemp >= 1000 && coldOutletTemp.toExponential(3) + ' K')
                || coldOutletTemp + ' K'}
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item
              label="Inlet Pressure"
              textAlign="right" >
              {formatSiUnit(Math.max(coldInletPres, 0), 1, 'Pa')}
            </LabeledList.Item>
            <LabeledList.Item
              label="Outlet Pressure"
              textAlign="right" >
              {formatSiUnit(coldOutletPres, 1, 'Pa')}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
