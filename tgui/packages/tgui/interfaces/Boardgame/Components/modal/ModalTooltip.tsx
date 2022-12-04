import { Box, Tooltip } from '../../../../components';

declare const React;

export type ModalTooltipProps = {
  text: string;
  tooltip: string;
  link?: string;
};

export const ModalTooltip = ({ text, tooltip, link }: ModalTooltipProps) => {
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Box
        style={{
          'padding': '0 0.5em',
        }}
        position="relative">
        {text}
        {link && (
          <a
            href={link}
            target="_blank"
            rel="noreferrer"
            style={{
              'padding': '0 0.5em',
            }}>
            (Wiki)
          </a>
        )}
      </Box>
    </Tooltip>
  );
};

export default ModalTooltip;
