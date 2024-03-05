/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
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
