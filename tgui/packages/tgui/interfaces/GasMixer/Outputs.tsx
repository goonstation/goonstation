/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import { Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { GasMixerData } from './types';

export const Outputs = () => {
  const { data } = useBackend<GasMixerData>();
  const { mixer_information } = data;

  return (
    <Section title="Outputs" height="100%" mx={1}>
      {mixer_information.Outoxygen} {mixer_information.Outnitrogen}{' '}
      {mixer_information.Outcarbon_dioxide} {mixer_information.Outtoxins}{' '}
      {mixer_information.Outfarts} {mixer_information.Outradgas}{' '}
      {mixer_information.Outnitrous_oxide} {mixer_information.Outoxygen_agent_b}
    </Section>
  );
};
