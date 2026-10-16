/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import type { ReactNode } from 'react';

type TerminalReadoutProps = {
  tag: string;
  label: string;
  value: ReactNode;
  /** Target number of characters before the value. */
  prefixLength?: number;
};

const DEFAULT_PREFIX_LENGTH = 25;

/** Aligns text columns when rendered inside a monospace container. */
export const TerminalReadout = ({
  tag,
  label,
  value,
  prefixLength = DEFAULT_PREFIX_LENGTH,
}: TerminalReadoutProps) => {
  const dots = '.'.repeat(
    Math.max(1, prefixLength - tag.length - label.length - 3),
  );
  return (
    <>
      {`${tag} ${label} ${dots} `}
      {value}
    </>
  );
};
