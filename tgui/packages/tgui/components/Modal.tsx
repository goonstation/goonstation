/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';

import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';
import { Dimmer } from './Dimmer';

type ModalProps = {
  /** If true, the modal will take up the full screen. */
  full?: boolean;
} & BoxProps;

export function Modal(props: ModalProps) {
  const { className, children, full, ...rest } = props;

  return (
    <Dimmer full={full}>
      <div
        className={classes(['Modal', className, computeBoxClassName(rest)])}
        {...computeBoxProps(rest)}
      >
        {children}
      </div>
    </Dimmer>
  );
}
