/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import type { AirInfo } from './types';

interface MixInfoProps {
  mix: AirInfo;
}
export const MixInfo = (props: MixInfoProps) => {
  const { mix } = props;
  return (
    <>
      {mix.gasses
        .filter((gas) => gas.Ratio > 0)
        .sort((gas1, gas2) => gas2.Ratio - gas1.Ratio)
        .map((gas) => (
          <div key={gas.Name} style={{ color: gas.Color }}>
            {gas.Name}: {gas.Ratio}%
          </div>
        ))}
      {mix.kpa && `Pressure: ${mix.kpa} kPa`}
      <br />
      {mix.temp && `Temperature: ${mix.temp} °C`}
    </>
  );
};
