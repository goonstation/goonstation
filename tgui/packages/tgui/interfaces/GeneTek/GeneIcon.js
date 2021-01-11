/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import { classes, pureComponentHooks } from 'common/react';
import { Box } from '../../components/Box';

export const GeneIcon = props => {
  const {
    name,
    size,
    style = {},
    ...rest
  } = props;
  if (size) {
    style["font-size"] = (size * 100) + "%";
  }
  return (
    <Box
      as="i"
      className={classes([
        "GeneIcon",
        "GeneIcon--" + name,
      ])}
      style={style}
      {...rest} />
  );
};

GeneIcon.defaultHooks = pureComponentHooks;
