import {
  AnimatedNumber,
  Box,
  Flex,
  Icon,
  RoundGauge,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { formatPressure } from '../format';
import { Window } from '../layouts';
import {
  getTemperatureColor,
  getTemperatureIcon,
} from './common/temperatureUtils';

interface AirAlarmData {
  boundaries;
  gasses;
  temperature;
  safe;
}

export const AirAlarm = () => {
  const { data } = useBackend<AirAlarmData>();

  const { boundaries, gasses, temperature, safe } = data;

  return (
    <Window width={300} height={350}>
      <Window.Content>
        <Section title="Status">
          {safe === 0 && (
            <Box align="center" fontSize={2} color="red">
              ALERT!
            </Box>
          )}
          {safe === 1 && (
            <Box align="center" fontSize={2} color="orange">
              CAUTION
            </Box>
          )}
          {safe === 2 && (
            <Box align="center" fontSize={2} color="green">
              OPTIMAL
            </Box>
          )}
          <Box
            align="center"
            nowrap
            p={1}
            fontSize={1}
            color={getTemperatureColor(temperature)}
          >
            <Box fontSize={1}>Atmospheric Temperature</Box>
            <Icon name={getTemperatureIcon(temperature)} pr={0.5} />
            <AnimatedNumber value={temperature} /> K
          </Box>
        </Section>
        <Section title="Gasses">
          <Flex>
            {boundaries.slice(0, 4).map((boundary, index) => (
              <GasInfo
                key={boundary.varname}
                partial_pressure={gasses[boundary.varname]}
                boundary={boundary}
                gas_index={index}
              />
            ))}
          </Flex>
          <br />
          <Flex>
            {boundaries.slice(4, 8).map((boundary, index) => (
              <GasInfo
                key={boundary.varname}
                partial_pressure={gasses[boundary.varname]}
                boundary={boundary}
                gas_index={index}
              />
            ))}
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};

export const GasInfo = (props) => {
  const { partial_pressure, boundary } = props;
  const max_display = 100;
  return (
    <Flex.Item grow>
      <Box align="center">{boundary.friend_name}</Box>
      <Box align="center">
        <RoundGauge
          align="center"
          size={1.75}
          value={partial_pressure}
          minValue={0}
          maxValue={max_display}
          alertAfter={
            isFinite(boundary.safe_max) ? boundary.safe_max : max_display
          }
          alertBefore={isFinite(boundary.safe_min) ? boundary.safe_min : 0}
          ranges={{
            bad: [0, max_display],
            average: [
              isFinite(boundary.safe_min) ? boundary.safe_min : 0,
              isFinite(boundary.safe_max) ? boundary.safe_max : max_display,
            ],
            good: [
              isFinite(boundary.good_min) ? boundary.good_min : 0,
              isFinite(boundary.good_max) ? boundary.good_max : max_display,
            ],
          }}
          format={formatPressure}
        />
      </Box>
    </Flex.Item>
  );
};
