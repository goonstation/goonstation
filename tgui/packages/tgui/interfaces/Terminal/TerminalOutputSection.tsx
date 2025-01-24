/**
 * @file
 * @copyright 2023
 * @author Garash2k (https://github.com/garash2k)
 * @license ISC
 */

import { useEffect } from 'react';
import { Section } from 'tgui-core/components';

import { Box } from '../../components';
import type { TerminalData } from './types';

type TerminalOutputSectionProps = Pick<
  TerminalData,
  'bgColor' | 'displayHTML' | 'fontColor'
>;

export const TerminalOutputSection = (props: TerminalOutputSectionProps) => {
  const { displayHTML, fontColor, bgColor } = props;

  useEffect(() => {
    // TODO: replace this with a useRef implementation once Section component supports it
    const sectionContentElement = document.querySelector(
      '#terminalOutput div.Section__content',
    );
    if (!sectionContentElement) {
      return;
    }
    sectionContentElement.scrollTop = sectionContentElement.scrollHeight;
  }, [displayHTML]);

  return (
    <Section
      backgroundColor={bgColor}
      scrollable
      fill
      container_id="terminalOutput"
    >
      <Box
        fontFamily="Consolas"
        fill
        color={fontColor}
        dangerouslySetInnerHTML={{ __html: displayHTML }}
      />
    </Section>
  );
};
