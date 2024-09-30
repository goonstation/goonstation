/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

// List of information about a pump
type PumpData = {
  tag: string; // Pump name
  netid: string; // Pump id
  power: string; // On or off
  target_output: number; // Current output target of the pump
  min_output: number;
  max_output: number;
  area_name: string; // Name of the area this pump is in
  processing: boolean; // Whether we are waiting for packet response or not
  alive: number; // A value of -1, 0, or 1 where -1 is checking if the pump is alive, 0 is dead, and 1 is alive
};

// List of areas which have pumps
type AreaList = {
  area_list: { [key: string]: { [key: string]: PumpData } };
  frequency: number;
};
