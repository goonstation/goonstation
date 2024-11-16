/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/garash2k)
 * @license MIT
 */

import { Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { GasMixerData } from './types';

export const Inputs = () => {
  const { data } = useBackend<GasMixerData>();
  const { mixer_information } = data;

  return (
    <Section title="Inputs" height="100%" mx={1}>
      <Section title="Input 1">
        {mixer_information.In1oxygen} {mixer_information.In1nitrogen}{' '}
        {mixer_information.In1carbon_dioxide} {mixer_information.In1toxins}{' '}
        {mixer_information.In1farts} {mixer_information.In1radgas}{' '}
        {mixer_information.In1nitrous_oxide}{' '}
        {mixer_information.In1oxygen_agent_b}
      </Section>
      <Section title="Input 2">
        {mixer_information.In2oxygen} {mixer_information.In2nitrogen}{' '}
        {mixer_information.In2carbon_dioxide} {mixer_information.In2toxins}{' '}
        {mixer_information.In2farts} {mixer_information.In2radgas}{' '}
        {mixer_information.In2nitrous_oxide}{' '}
        {mixer_information.In2oxygen_agent_b}
      </Section>
    </Section>
  );
};
