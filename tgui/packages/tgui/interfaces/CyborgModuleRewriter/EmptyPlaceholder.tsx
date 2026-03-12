/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { classes } from 'common/react';
import { PropsWithChildren } from 'react';

import * as styles from './style';

interface EmptyPlaceholderProps {
  className?: string;
}

export const EmptyPlaceholder = (
  props: PropsWithChildren<EmptyPlaceholderProps>,
) => {
  const { children, className } = props;
  const cn = classes([styles.EmptyPlaceholder, className]);
  return <div className={cn}>{children}</div>;
};
