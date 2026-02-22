/**
 * @file
 * @copyright 2023
 * @author garash2k
 * @license ISC
 */
import { Box, Image } from 'tgui-core/components';

import { resource } from '../../../goonstation/cdn';
import type { AlertContentWindow } from '../types';

const TGInterfaceContentWindow = () => {
  return (
    <>
      <Box>
        Would you rather use a /tg/ style interface? If so, checkout the options
        in the drop-down menu at the top of the screen - &apos;Game&apos;.
      </Box>
      <Box my={1.5}>
        Save your profile in Character Setup to dismiss this alert.
      </Box>
      <Image src={resource('images/tg_control_info.png')} />
    </>
  );
};

export const acw: AlertContentWindow = {
  width: 470,
  height: 320,
  title: 'Use /tg/ style interface?',
  component: TGInterfaceContentWindow,
};
