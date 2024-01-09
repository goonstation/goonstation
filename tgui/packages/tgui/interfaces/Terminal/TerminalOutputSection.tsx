/**
 * @file
 * @copyright 2023
 * @author Garash2k (https://github.com/garash2k)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { TerminalData, TerminalOutputSectionProps } from './types';
import { Box, Section } from '../../components';

export const TerminalOutputSection = (props: TerminalOutputSectionProps, context) => {
  const { data } = useBackend<TerminalData>(context);
  const {
    fontColor,
    bgColor,
  } = data;
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
