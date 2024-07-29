/**
 * @file
 * @copyright 2024
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

export interface TransceptionInterlinkData {
  pads: PadData[];
  crate_count: number;
}

export interface PadData {
  device_netid: string; // key in the interlink's manifest list
  identifier: string; // unique text identifier of the pad
  target_id: string; // the pad's network ID (i.e. target pad)
  location: string; // location (area) of the pad
  array_link: string; // status code of the pad
}
