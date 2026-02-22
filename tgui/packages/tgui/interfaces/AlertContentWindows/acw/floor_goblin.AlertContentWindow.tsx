/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { Box, Image } from 'tgui-core/components';

import { resource } from '../../../goonstation/cdn';
import { AlertContentWindow } from '../types';

const FloorGoblinContentWindow = () => {
  return (
    <>
      <Box as="h1" textAlign="center" fontSize={2.5}>
        You are a Floor goblin!
      </Box>
      <Image
        src={resource('images/antagTips/floor-goblin.png')}
        width="32px"
        mx="auto"
        mb={2}
        style={{ display: 'block' }}
      />
      <Image
        src={resource('images/antagTips/floor-goblin-objective.png')}
        width="500px"
        mx="auto"
        style={{ display: 'block' }}
      />
    </>
  );
};

export const acw: AlertContentWindow = {
  title: 'Floor Goblin Tips',
  height: 630,
  component: FloorGoblinContentWindow,
};
