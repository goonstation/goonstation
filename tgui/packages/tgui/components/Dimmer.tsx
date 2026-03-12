/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';

import { Box, BoxProps } from './Box';

type DimmerProps = {
  /** If true, the dimmer will take up the full screen. */
  full?: boolean;
} & BoxProps;

export function Dimmer(props: DimmerProps) {
  const { className, children, full, ...rest } = props;

  return (
    <Box
      className={classes(['Dimmer', !!full && 'Dimmer--full', className])}
      {...rest}
    >
      <div className="Dimmer__inner">{children}</div>
    </Box>
  );
}
