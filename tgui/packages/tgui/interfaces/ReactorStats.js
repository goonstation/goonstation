/**
 * @file
 * @copyright 2022
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Box, Chart, Divider, LabeledList, Collapsible, Section, Stack } from '../components';
import { Window } from '../layouts';

/**
 * Helper function to transform the data into something displayable
 * Lovingly made by Mordent and adapted
 * @param {*} statsData - [ { foo: v, bar: v2 }, { foo: v3, bar: v4 } ]
 * @returns - { foo: [[i, v], [i+1, v2], ...], bar: [[i, v3], [i+1, v4], ...] }
 */
const processStatsData = statsData => {
  if ((statsData ?? []).length === 0) {
    return null; // or if you know the keys in advance, can return a constant with them having empty arrays as values
  }
  // intialize our data structure
  const keys = Object.keys(statsData[0]);

  const resolvedData = keys.reduce((acc, curr) => {
    acc[curr] = [];
    return acc;
  }, {});

  for (let statsDataIndex = 0; statsDataIndex < statsData.length; statsDataIndex++) {
    const tegDatum = statsData[statsDataIndex];
    for (let keyIndex = 0; keyIndex < keys.length; keyIndex++) {
      const key = keys[keyIndex];
      const scientificIfOverMil = v =>
        `${ v >= 1000000 ? v.toExponential(3) : v}`; // string !!!! to exponent do later
      // x,y coords for graph (y defaults to 0)
      resolvedData[key].push([statsDataIndex, scientificIfOverMil(tegDatum[key]) ?? 0]); // 0 but none later
    }
  }
  return resolvedData;
};


/**
 * Helper function to get the maximum value of our stats information for display
 * @param {*} stats - { [i, value], [i+1, value2], ...}
 * @returns float maximum value
 */
const getStatsMax = stats => {
  let found_maximum = 0; // Chart always starts at 0
  for (const index in stats) {
    const stat = stats[index][1]; // get the value
    if (stat > found_maximum) {
      found_maximum = stat;
    }
  }
  return found_maximum;
};

/**
 * Generates stack items of labeled charts for display
 * @param {*} stats - { foo: [[i, v], [i+1, v2], ...], bar: [[i, v3], [i+1, v4], ...] }
 * @returns JSX of stack items
 */
const generateChartsFromStats = stats => {
  return Object.entries(stats).map(([key, chart_data], index) => (
    <Stack.Item key={key} mt={0.5} ml={index === 0 ? 1 : undefined} >
      <Box>
        {key}: {chart_data[chart_data.length - 1][1]}
      </Box>
      <Chart.Line
        height="3em"
        width="20em"
        data={chart_data}
        rangeX={[0, chart_data.length - 1]}
        rangeY={[0, getStatsMax(chart_data)]}
        strokeColor="	rgba(55,170,25, 1)"
        fillColor="rgba(55,170,25, 0.25)" />
    </Stack.Item>
  ));
};

export const ReactorStats = (props, context) => {
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
      height="550"
      width="760"
      theme="retro-dark"
    >
      <Window.Content>
        {!turnedOn
          ? (<Box> Unpowered </Box>)
          :(
            <Box>
              <Section title="TEG Data">
                <Stack
                  wrap="wrap"
                  justify="space-around"
                  ml={-1}
                >
                  { generateChartsFromStats(tegStats) }
                </Stack>
              </Section>
              <Section title="Chamber Data">
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
