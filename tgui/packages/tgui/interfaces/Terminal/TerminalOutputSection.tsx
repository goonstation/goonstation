/**
 * @file
 * @copyright 2023
 * @author Garash2k (https://github.com/garash2k)
 * @license ISC
 */

import { Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Box } from '../../components';
import { TerminalData, TerminalOutputSectionProps } from './types';

export const TerminalOutputSection = (props: TerminalOutputSectionProps) => {
  const { data } = useBackend<TerminalData>();
  const { fontColor, bgColor } = data;
  const { displayHTML } = props;

  return (
    <Section backgroundColor={bgColor} scrollable fill id="terminalOutput">
      <Box
        fontFamily="Consolas"
        fill
        color={fontColor}
        dangerouslySetInnerHTML={{ __html: displayHTML }}
      />
    </Section>
  );
};
