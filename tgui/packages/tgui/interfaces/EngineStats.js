/**
 * @file
 * @copyright 2022
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Box, Chart, Modal, Section, Stack, Button } from '../components';
import { Window } from '../layouts';
import { formatSiUnit } from '../format';
import { processStatsData, getStatsMax } from './common/graphUtils';

/**
 * Generates stack items of labeled charts for display
 * @param {*} stats - { foo: [[i, v], [i+1, v2], ...], bar: [[i, v3], [i+1, v4], ...] }
 * @returns JSX of stack items
 */
const generateChartsFromStats = stats => {
  return Object.entries(stats).map(([key, chart_data], index) => (
    // margin fuckery is to remove the extra left margin on the first stack item for alignment reasons
    <Stack.Item key={key} mt={0.5} ml={index === 0 ? 1 : undefined} >
      <Box>
        { key.split("|")[0] }
        :&nbsp;
        {
          chart_data[chart_data.length - 1][1] === 0
            ? ("No Data")
            : (formatSiUnit(chart_data[chart_data.length - 1][1], 0, key.split("|")[1]))
        }
      </Box>
      <Chart.Line
        height="3.5em"
        width="20em"
        data={chart_data}
        rangeX={[0, chart_data.length - 1]}
        rangeY={[0, getStatsMax(chart_data)]}
        strokeColor="	rgba(55,170,25, 1)"
        fillColor="rgba(55,170,25, 0.25)" />
    </Stack.Item>
  ));
};


export const EngineStats = (props, context) => {
  const { act, data } = useBackend(context);
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
      height="560"
      width="760"
      theme="retro-dark"
      title="Engine Statistics"
    >
      <Window.Content>
        {!turnedOn || !tegStats || !chamberStats // Need stats or window will freak out
          ? (
            // Turned off screen
            <Modal
              textAlign="center"
              width={20}
              height={5}
              fontSize={2}
              fontFamily="Courier">
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
          )
          : (
            <Box>
              <Section title={
                <Box>
                  TEG Data
                  <Button
                    tooltip="Power"
                    icon="power-off"
                    color="caution"
                    position="absolute"
                    right={0.25}
                    top={0.25}
                    onClick={() => act('toggle-power')}
                  />
                </Box>
              }>
                <Stack
                  wrap="wrap"
                  justify="space-around"
                  ml={-1}
                >
                  { generateChartsFromStats(tegStats) }
                </Stack>
              </Section>
              <Section title="Combustion Chamber Data">
                <Stack
                  wrap="wrap"
                  justify="space-around"
                  ml={-1}
                >
                  { generateChartsFromStats(chamberStats) }
                </Stack>
              </Section>
            </Box>
          )}
      </Window.Content>
    </Window>
  );
};
