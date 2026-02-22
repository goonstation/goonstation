/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import { Box, LabeledList, NoticeBox } from 'tgui-core/components';

import { formatPressure } from '../../format';
import type { AirInfo } from './types';

interface MixInfoProps {
  mix: AirInfo;
}
export const MixInfo = (props: MixInfoProps) => {
  const { mix } = props;

  const shownGasses = mix.gasses.filter((gas) => gas.Ratio > 0);

  return (
    <LabeledList>
      {shownGasses.length > 0 ? (
        <>
          {shownGasses
            .sort((gas1, gas2) => gas2.Ratio - gas1.Ratio)
            .map((gas) => (
              <LabeledList.Item
                key={gas.Name}
                label={gas.Name}
                labelColor={gas.Color}
              >
                <Box as="span" color={gas.Color}>
                  {gas.Ratio}%
                </Box>
              </LabeledList.Item>
            ))}
          <LabeledList.Item label="Pressure">
            {formatPressure(mix.kpa!)}
          </LabeledList.Item>
          <LabeledList.Item label="Temperature">{mix.temp} °C</LabeledList.Item>
        </>
      ) : (
        <NoticeBox info>No gas detected.</NoticeBox>
      )}
    </LabeledList>
  );
};
