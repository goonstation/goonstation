/**
 * @file
 * @copyright 2022
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Box, Chart, LabeledList, Section, Divider } from '../components';
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
      // will insert 'undefined' if not present, if you want different handling here then I guess do it?
      resolvedData[key].push(tegDatum[key]);
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
    meterData,
  } = data;

  const tegStats = processStatsData(tegData);
  const chamberStats = processStatsData(chamberData);
  const meterStats = processStatsData(meterData);

  return (
    <Window
      height="520"
      width="300" >
      <Window.Content>
        {!turnedOn
          ? (<Box> Unpowered </Box>)
          :(
            <Section title="TEG Data">
              {tegStats.map(({ key, value: data }) => (
                <Section key={key}>
                  <LabeledList>
                    <LabeledList.Item label={key} />
                  </LabeledList>
                  <Chart.Line
                    key={key}
                    height="5em"
                    data={data}
                    rangeX={[0, data.length - 1]}
                    rangeY={[0, Math.max(...data)]}
                    strokeColor="rgba(1, 184, 170, 1)"
                    fillColor="rgba(1, 184, 170, 0.25)" />
                </Section>
              ))}
            </Section>
          )}
      </Window.Content>
    </Window>
  );
};
