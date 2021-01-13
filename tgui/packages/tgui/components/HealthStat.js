/**
* @file
* @copyright 2020
* @author ThePotato97 (https://github.com/ThePotato97)
* @license ISC
*/

import { classes } from 'common/react';
import { COLORS } from "../constants";
import { computeBoxClassName, Box } from './Box';
/**
* A box that applies a color to its contents depending on the damage type.
* Accepted types: oxy, toxin, burn, brute.
*/
export const HealthStat = props => {
  const {
    type,
    children,
    className,
    ...rest
  } = props;
  rest.color = COLORS.damageType[type] & COLORS.damageType[type];
  return (
    <Box
      {...rest}
      className={classes([
        'HealthStat',
        className,
        computeBoxClassName(rest),
      ])}
      color={COLORS.damageType[type]}>
      {children}
    </Box>
  );
};
