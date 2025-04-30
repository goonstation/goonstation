/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

interface SimulatorData {
  tank_one: TankData;
  tank_two: TankData;
  host_id: string;
  vr_bomb: string;
  is_ready: boolean;
  readiness_dialogue: string;
  cooldown: number;
  panel_open: boolean;
  net_number: number;
}

interface TankData {
  name: string;
  pressure: number;
  maxPressure: number;
}
