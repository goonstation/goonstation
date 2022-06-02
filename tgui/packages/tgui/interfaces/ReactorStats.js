/**
 * @file
 * @copyright 2022
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Box, Chart, LabeledList, Section } from '../components';
import { Window } from '../layouts';

/**
 * Helper function to transform the data into something displayable
 * Lovingly made by Mordent
 * @param {*} statsData - [ { foo: 1, bar: 2 }, { foo: 3, bar: 4 } ]
 * @returns - { foo: [1, 3], bar: [2, 4] }
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
      // x,y coords for graph (y defaults to 0)
      resolvedData[key].push([statsDataIndex, tegDatum[key] ?? 0]);
    }
  }
  return resolvedData;
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

  // eslint-disable-next-line max-len
  const boob = [[0, 66780.8], [1, 66680.6], [2, 66590.5], [3, 66510.1], [4, 66417.1], [5, 66256.9], [6, 66068.4], [7, 65906.3], [8, 65754], [9, 65621.8], [10, 65514.2], [11, 65423.9], [12, 65357.2], [13, 65305.9], [14, 65279.7], [15, 65264.6], [16, 65262.4], [17, 65266.3], [18, 65286.2], [19, 65310], [20, 65339.6], [21, 65382.2], [22, 65428.8], [23, 65483.6], [24, 65546.8], [25, 65620.4], [26, 65700.7], [27, 65788.1], [28, 65888.1], [29, 65999.2], [30, 66116.2], [31, 66243.8], [32, 66380.6], [33, 66526.5], [34, 66679.1], [35, 66683.2], [36, 66375.9], [37, 66078.3], [38, 65795.6], [39, 65521.4], [40, 65263.5], [41, 65013.9], [42, 64771.6], [43, 64545.1], [44, 64323.9], [45, 64115.5], [46, 63912.4], [47, 63717], [48, 63525.9], [49, 63374.7]];

  const tegCharts = Object.entries(tegStats).map(([key, chart_data], _index) => (
    <Box key={key}>
      <LabeledList>
        <LabeledList.Item label={key}>
          {chart_data[chart_data.length -1]}
        </LabeledList.Item>
      </LabeledList>
      <Chart.Line
        height="5em"
        data={chart_data}
        rangeX={[0, data.length - 1]}
        rangeY={[0, Math.max(...data)]}
        strokeColor="rgba(1, 184, 170, 1)"
        fillColor="rgba(1, 184, 170, 0.25)" />
    </Box>
  ));

  const historyData = boob.map((value, i) => [i, value]);
  const historyMax = Math.max(...boob);

  return (
    <Window
      height="520"
      width="600"
      scrollable>
      <Window.Content>
        {!turnedOn
          ? (<Box> Unpowered </Box>)
          :(
            <Section title="TEG Data">
              <Chart.Line
                height="5em"
                data={historyData}
                rangeX={[0, historyData.length - 1]}
                rangeY={[0, historyMax]}
                strokeColor="rgba(1, 184, 170, 1)"
                fillColor="rgba(1, 184, 170, 0.25)" />
              { tegCharts }
            </Section>
          )}
      </Window.Content>
    </Window>
  );
};
