/**
 * @file
 * @copyright 2022
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import {
  Box,
  Button,
  Chart,
  Modal,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { formatSiUnit } from '../format';
import { Window } from '../layouts';
import { getStatsMax, processStatsData } from './common/graphUtils';

interface EngineStatsData {
  chamberData;
  tegData;
  turnedOn;
}

type StatsData = Record<string, any[]>;

/**
 * Generates stack items of labeled charts for display
 * @param {*} stats - { foo: [[i, v], [i+1, v2], ...], bar: [[i, v3], [i+1, v4], ...] }
 * @returns JSX of stack items
 */
const generateChartsFromStats = (stats: StatsData) => {
  return Object.entries(stats).map(([key, chart_data], index) => (
    // margin fuckery is to remove the extra left margin on the first stack item for alignment reasons
    <Stack.Item key={key} mt={0.5} ml={index === 0 ? 1 : undefined}>
      <Box>
        {key.split('|')[0]}
        :&nbsp;
        {chart_data[chart_data.length - 1][1] === 0
          ? 'No Data'
          : formatSiUnit(
              chart_data[chart_data.length - 1][1],
              0,
              key.split('|')[1],
            )}
      </Box>
      <Chart.Line
        height="3.5em"
        width="20em"
        data={chart_data}
        rangeX={[0, chart_data.length - 1]}
        rangeY={[0, getStatsMax(chart_data)]}
        strokeColor="	rgba(55,170,25, 1)"
        fillColor="rgba(55,170,25, 0.25)"
      />
    </Stack.Item>
  ));
};

export const EngineStats = () => {
  const { act, data } = useBackend<EngineStatsData>();
  const {
    turnedOn,
    tegData,
    chamberData,
    // meterData,
  } = data;

  const tegStats = processStatsData(tegData);
  const chamberStats = processStatsData(chamberData);
  // const meterStats = processStatsData(meterData);

  return (
    <Window
      height={595}
      width={760}
      theme="retro-dark"
      title="Engine Statistics"
    >
      <Window.Content>
        {!turnedOn || !tegStats || !chamberStats ? ( // Need stats or window will freak out
          // Turned off screen
          <Modal
            textAlign="center"
            width={20}
            height={5}
            fontSize={2}
            fontFamily="Courier"
          >
            POWER ON
            <Button
              tooltip="Power"
              icon="power-off"
              selected={turnedOn}
              color="caution"
              ml={3}
              onClick={() => act('toggle-power')}
            />
          </Modal>
        ) : (
          <Box>
            <Section
              title="TEG Data"
              buttons={
                <Button
                  tooltip="Power"
                  icon="power-off"
                  color="caution"
                  onClick={() => act('toggle-power')}
                />
              }
            >
              <Stack wrap="wrap" justify="space-around" ml={-1}>
                {generateChartsFromStats(tegStats)}
              </Stack>
            </Section>
            <Section title="Combustion Chamber Data">
              <Stack wrap="wrap" justify="space-around" ml={-1}>
                {generateChartsFromStats(chamberStats)}
              </Stack>
            </Section>
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};
