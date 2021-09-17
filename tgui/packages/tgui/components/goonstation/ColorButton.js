/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Box } from '../Box';
import { Button } from '../Button';
import { ColorBox } from '../ColorBox';

export const ColorButton = props => {
  const {
    color,
    ...rest
  } = props;

  return (
    <Button {...rest}>
      <ColorBox color={color} mr="5px" />
      <Box as="code">{color}</Box>
    </Button>
  );
};
