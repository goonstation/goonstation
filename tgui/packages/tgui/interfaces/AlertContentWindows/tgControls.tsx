/**
 * @file
 * @copyright 2023
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from './types';
import { Box, Image } from '../../components';

export const tgControls: AlertContentWindow = {
  width: 470,
  height: 320,
  title: "Use /tg/ style interface?",
  content: (
    <>
      <Box>
        Would you rather use a /tg/ style interface?
        If so, checkout the options in the drop-down menu at the top of the screen - &apos;Game&apos;.
      </Box>
      <Box my={1.5}>
        Save your profile in Character Setup to dismiss this alert.
      </Box>
      <Image src="tg_control_info.png" />
    </>),
};
