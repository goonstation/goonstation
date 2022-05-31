/**
 * @file
 * @copyright 2022
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Box, Chart, LabeledList, Section, Divider } from '../components';
import { formatPower, formatSiUnit } from '../format';
import { Window } from '../layouts';

export const ReactorStats = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    turnedOn,
    tegData,
    chamberData,
    meterData,
  } = data;
  const tegMap = tegData.map((value, i) => [i, value]);
  const tegMax = Math.max(...tegData["Output"]);

  const formatTemperature = temperature =>
    `${temperature >= 1000 ? temperature.toExponential(3) : temperature} K`;
  return (
    <Window
      height="520"
      width="300" >
      <Window.Content>
        {!turnedOn
          ? (<Box> Unpowered </Box>)
          :(
            <Section title="Status">
              <LabeledList>
                <LabeledList.Item label="Output History" />
              </LabeledList>
              <Chart.Line
                height="5em"
                data={tegMap}
                rangeX={[0, tegMap.length - 1]}
                rangeY={[0, tegMax]}
                strokeColor="rgba(1, 184, 170, 1)"
                fillColor="rgba(1, 184, 170, 0.25)" />
            </Section>
          )}
      </Window.Content>
    </Window>
  );
};
