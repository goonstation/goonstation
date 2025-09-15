/**
 * @file
 * @copyright 2020
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import {
  Box,
  Chart,
  Divider,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { formatPower, formatSiUnit } from '../format';
import { Window } from '../layouts';

interface TEGData {
  output;
  history;
  hotCircStatus;
  hotInletTemp;
  hotOutletTemp;
  hotInletPres;
  hotOutletPres;
  coldCircStatus;
  coldInletTemp;
  coldOutletTemp;
  coldInletPres;
  coldOutletPres;
}

export const TEG = () => {
  const { data } = useBackend<TEGData>();
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
  const formatTemperature = (temperature) =>
    `${temperature >= 1000 ? temperature.toExponential(3) : temperature} K`;
  return (
    <Window height={525} width={300}>
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
            fillColor="rgba(1, 184, 170, 0.25)"
          />
          <Divider />
          <LabeledList>
            <LabeledList.Item label="Energy Output" textAlign="right">
              {formatPower(output)}
            </LabeledList.Item>
            <LabeledList.Item label="Hot Gas Circulator" textAlign="right">
              <Box
                color={
                  (hotCircStatus && hotInletTemp && 'good') ||
                  (hotCircStatus && 'average') ||
                  'bad'
                }
              >
                {(hotCircStatus && hotInletTemp && 'OK') ||
                  (hotCircStatus && 'Idle') ||
                  'ERROR'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Cold Gas Circulator" textAlign="right">
              <Box
                color={
                  (coldCircStatus && coldInletTemp && 'good') ||
                  (coldCircStatus && 'average') ||
                  'bad'
                }
              >
                {(coldCircStatus && coldInletTemp && 'OK') ||
                  (coldCircStatus && 'Idle') ||
                  'ERROR'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Hot Loop">
          <LabeledList>
            <LabeledList.Item label="Inlet Temp" textAlign="right">
              {formatTemperature(hotInletTemp)}
            </LabeledList.Item>
            <LabeledList.Item label="Outlet Temp" textAlign="right">
              {formatTemperature(hotOutletTemp)}
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Inlet Pressure" textAlign="right">
              {formatSiUnit(Math.max(hotInletPres, 0), 1, 'Pa')}
            </LabeledList.Item>
            <LabeledList.Item label="Outlet Pressure" textAlign="right">
              {formatSiUnit(hotOutletPres, 1, 'Pa')}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Cold Loop">
          <LabeledList>
            <LabeledList.Item label="Inlet Temp" textAlign="right">
              {formatTemperature(coldInletTemp)}
            </LabeledList.Item>
            <LabeledList.Item label="Outlet Temp" textAlign="right">
              {formatTemperature(coldOutletTemp)}
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Inlet Pressure" textAlign="right">
              {formatSiUnit(Math.max(coldInletPres, 0), 1, 'Pa')}
            </LabeledList.Item>
            <LabeledList.Item label="Outlet Pressure" textAlign="right">
              {formatSiUnit(coldOutletPres, 1, 'Pa')}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
