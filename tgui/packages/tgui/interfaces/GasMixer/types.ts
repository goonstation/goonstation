/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

export type GasMixerData = {
  name: string;
  mixerid: string;
  mixer_information: mixerInformation;
  MAX_PRESSURE: number;
};

type mixerInformation = {
  tag: string;
  timestamp: number;
  target_pressure: number;
  pump_status: 'Online' | 'Offline';

  in1: airInfo;
  in2: airInfo;

  i1trans: number; // Input 1 ratio
  i2trans: number; // Input 2 ratio

  out: airInfo;

  address_tag: string;
  sender: string;
};

export type airInfo = {
  gasses: Array<gasInfo>;
  kpa?: number;
  temp?: number;
};

type gasInfo = {
  Name: string;
  Color: string;
  Ratio: number;
};
