/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import { LabeledList } from 'tgui-core/components';

import type { AirInfo } from './types';

interface MixInfoProps {
  mix: AirInfo;
}
export const MixInfo = (props: MixInfoProps) => {
  const { mix } = props;
  return (
    <LabeledList>
      {mix.gasses
        .filter((gas) => gas.Ratio > 0)
        .sort((gas1, gas2) => gas2.Ratio - gas1.Ratio)
        .map((gas) => (
          <LabeledList.Item key={gas.Name} label={gas.Name}>
            <span style={{ color: gas.Color }}>{gas.Ratio}%</span>
          </LabeledList.Item>
        ))}
      <LabeledList.Item label="Pressure">{mix.kpa} kPa</LabeledList.Item>
      <LabeledList.Item label="Temperature">{mix.temp} °C</LabeledList.Item>
    </LabeledList>
  );
};
