/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import { classes } from 'common/react';
import { memo } from 'react';
import { Box } from 'tgui-core/components';

interface GeneIconProps {
  name;
  size;
  style?;
}

export const GeneIcon = memo((props: GeneIconProps) => {
  const { name, size, style = {}, ...rest } = props;
  if (size) {
    style['fontSize'] = size * 100 + '%';
  }
  return (
    <Box
      as="i"
      className={classes(['GeneIcon', 'GeneIcon--' + name])}
      style={style}
      {...rest}
    />
  );
});
