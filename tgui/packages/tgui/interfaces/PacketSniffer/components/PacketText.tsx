/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import type { PropsWithChildren } from 'react';
import { Box } from 'tgui-core/components';

// Unbroken payloads must wrap inside their flex column.
export const PacketText = (props: PropsWithChildren) => (
  <Box preserveWhitespace style={{ overflowWrap: 'anywhere' }}>
    {props.children}
  </Box>
);
