import { BooleanLike, classes } from 'common/react';
import { Box } from 'tgui-core/components';

interface LedProps {
  flashing: BooleanLike;
}

export const Led = (props: LedProps) => {
  return <Box className={classes(['led-red', props.flashing && 'flashing'])} />;
};
