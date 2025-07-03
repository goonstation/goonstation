/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

import { Box } from 'tgui-core/components';

type CenteredTextProps = {
  position?: string;
  width?: number | string;
  height?: number | string;
  text: string;
};

export const CenteredText = (props: CenteredTextProps) => {
  const { position, width, height, text } = props;
  return (
    <Box
      preserveWhitespace
      inline
      position={position}
      width={width !== undefined ? width : '100%'}
      height={height !== undefined ? height : '100%'}
      lineHeight={height !== undefined ? height : '100%'}
      textAlign="center"
      px={0.5} // comfort padding
    >
      <span
        style={{
          display: 'inline-block',
          verticalAlign: 'middle',
          lineHeight: 'normal',
        }}
      >
        {text}
      </span>
    </Box>
  );
};
