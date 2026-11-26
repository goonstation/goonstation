/**
 * @file
 * @copyright 2025
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */

import { type BooleanLike, classes } from 'common/react';
import { Box } from 'tgui-core/components';

interface LedProps {
  flashing: BooleanLike;
  litColor: string;
  unlitColor: string;
}

export const Led = (props: LedProps) => {
  return (
    <Box
      className={classes(['led', props.flashing && 'flashing'])}
      style={{
        '--unlit-color': props.unlitColor,
        '--lit-color': props.litColor,
      }}
    />
  );
};
