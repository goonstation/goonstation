/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { classes } from 'common/react';
import { Box, BoxProps } from '../Box';

interface PlaceholderProps extends BoxProps {}

export const Placeholder = (props: PlaceholderProps) => {
  const {
    children = 'No results found',
    className,
    ...rest
  } = props;
  const cn = classes(['placeholder', className]);
  return (
    <Box
      className={cn}
      color="label"
      italic
      {...rest}
    >
      {children}
    </Box>
  );
};
