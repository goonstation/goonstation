/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { classes, pureComponentHooks } from 'common/react';
import * as styles from './style';

export const EmptyPlaceholder = props => {
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
