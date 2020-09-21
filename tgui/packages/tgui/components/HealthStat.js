import { classes } from 'common/react';
import { COLORS } from "../constants";
import { computeBoxClassName, Box } from './Box';

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
