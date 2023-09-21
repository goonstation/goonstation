/**
 * @file
 * @copyright 2023
 * @author Garash2k (https://github.com/garash2k)
 * @license ISC
 */

export type TerminalOutputSectionProps = Pick<TerminalData, 'displayHTML'>

export type PeripheralData = {
  card: string,
  icon: string,
  label: string,
  Clown?: boolean,
  color: any,
  index: number,
};

export type TerminalData = {
  displayHTML: string,
  TermActive: boolean,
  windowName: string,
  fontColor: string,
  bgColor: string,
  peripherals: Array<PeripheralData>
};
