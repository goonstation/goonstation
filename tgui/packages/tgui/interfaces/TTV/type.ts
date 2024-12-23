/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

interface TransferValveParams {
  opened: boolean;
  tank_one: TankData;
  tank_two: TankData;
  device: string;
}

interface TankData {
  name: string;
  num: number;
  pressure: number;
  maxPressure: number;
}
