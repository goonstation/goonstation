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

  In1oxygen: number;
  In1nitrogen: number;
  In1carbon_dioxide: number;
  In1toxins: number;
  In1farts: number;
  In1radgas: number;
  In1nitrous_oxide: number;
  In1oxygen_agent_b: number;
  // in1tg: number; // Out with trace gasses
  in1kpa?: number;
  in1temp?: number;

  In2oxygen: number;
  In2nitrogen: number;
  In2carbon_dioxide: number;
  In2toxins: number;
  In2farts: number;
  In2radgas: number;
  In2nitrous_oxide: number;
  In2oxygen_agent_b: number;
  // in2tg: number; // Out with trace gasses
  in2kpa?: number;
  in2temp?: number;

  i1trans: number; // Input 1 ratio
  i2trans: number; // Input 2 ratio

  Outoxygen: number;
  Outnitrogen: number;
  Outcarbon_dioxide: number;
  Outtoxins: number;
  Outfarts: number;
  Outradgas: number;
  Outnitrous_oxide: number;
  Outoxygen_agent_b: number;
  // outtg: number; // Out with trace gasses
  outkpa?: number;
  outtemp?: number;

  address_tag: string;
  sender: string;
};
