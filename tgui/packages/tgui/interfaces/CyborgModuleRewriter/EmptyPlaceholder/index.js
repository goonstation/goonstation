/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { classes } from "common/react";
import { EmptyPlaceholderCn } from '../style';

const EmptyPlaceholder = props => {
  const {
    children,
    className,
  } = props;
  const cn = classes([
    EmptyPlaceholderCn,
    className,
  ]);
  return (
    <div className={cn}>{children}</div>
  );
};

export default EmptyPlaceholder;
