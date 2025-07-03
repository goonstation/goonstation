/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Box, Button, ColorBox } from 'tgui-core/components';

import { BoxProps } from '../Box';

interface ColorButtonProps extends BoxProps {
  color: string;
}

export const ColorButton = (props: ColorButtonProps) => {
  const { color, ...rest } = props;

  return (
    <Button {...rest}>
      <ColorBox color={color} mr="5px" />
      <Box as="code">{color}</Box>
    </Button>
  );
};
