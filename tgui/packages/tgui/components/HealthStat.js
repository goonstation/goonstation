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
    content,
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
      {content}
    </Box>
  );
};
