/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import { Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { SupplyConsoleData } from './type';

export const SupplyConsoleMarketTab = () => {
  const { data } = useBackend<SupplyConsoleData>();
  return <Section title="Shipping Market"> Todo </Section>;
};
