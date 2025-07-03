/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import { BooleanLike } from 'common/react';

export type GasMixerData = {
  name: string;
  mixerid: string;
  mixer_information: MixerInformation;
  MAX_PRESSURE: number;
  allowed: BooleanLike;
};

type MixerInformation = {
  tag: string;
  timestamp: number;
  target_pressure: number;
  pump_status: 'Online' | 'Offline';

  in1: AirInfo;
  in2: AirInfo;

  in1_ratio: number;
  in2_ratio: number;

  out: AirInfo;

  address_tag: string;
  sender: string;
};

export type AirInfo = {
  gasses: Array<GasInfo>;
  kpa?: number;
  temp?: number;
};

type GasInfo = {
  Name: string;
  Color: string;
  Ratio: number;
};
