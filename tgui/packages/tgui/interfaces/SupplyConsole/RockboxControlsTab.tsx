/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license MIT
 */

import { Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { SupplyConsoleData } from './type';

export const SupplyConsoleRockboxControlsTab = () => {
  const { data } = useBackend<SupplyConsoleData>();
  return <Section title="Rockbox Controls"> Todo </Section>;
};
