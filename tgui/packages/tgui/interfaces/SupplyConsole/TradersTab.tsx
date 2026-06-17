/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import { Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { SupplyConsoleData } from './type';

export const SupplyConsoleTradersTab = () => {
  const { data } = useBackend<SupplyConsoleData>();
  return <Section title="Traders"> Todo </Section>;
};
