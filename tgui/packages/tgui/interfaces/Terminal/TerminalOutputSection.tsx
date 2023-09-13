/**
 * @file
 * @copyright 2023
 * @author Garash2k (https://github.com/garash2k)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { TerminalData } from './types';
import { Section, Box } from '../../components';

export const TerminalOutputSection = (_props, context) => {
  const { data } = useBackend<TerminalData>(context);
  const {
    displayHTML,
    fontColor,
    bgColor,
  } = data;

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
