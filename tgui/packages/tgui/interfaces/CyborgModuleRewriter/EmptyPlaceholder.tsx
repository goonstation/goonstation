/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { SFC } from 'inferno';
import { classes, pureComponentHooks } from 'common/react';
import * as styles from './style';

interface EmptyPlaceholderProps {
  className?: string,
}

export const EmptyPlaceholder: SFC<EmptyPlaceholderProps> = props => {
  const {
    children,
    className,
  } = props;
  const cn = classes([
    styles.EmptyPlaceholder,
    className,
  ]);
  return (
    <div className={cn}>{children}</div>
  );
};

EmptyPlaceholder.defaultHooks = pureComponentHooks;
