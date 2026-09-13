/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import type { ReactNode } from 'react';
import { Box } from 'tgui-core/components';

// Unbroken payloads must wrap inside their flex column.
export const PacketText = (props: { children: ReactNode }) => (
  <Box preserveWhitespace style={{ overflowWrap: 'anywhere' }}>
    {props.children}
  </Box>
);
