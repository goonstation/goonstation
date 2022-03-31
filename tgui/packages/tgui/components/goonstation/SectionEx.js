/**
 * @file
 * @copyright 2022
 * @author CodeJester (https://github.com/codeJester27)
 * @license ISC
 */

import { classes } from 'common/react';
import { computeBoxClassName } from '../Box';
import { Section } from '../Section';

export const SectionEx = props => {
  const {
    className,
    capitalize,
    ...rest
  } = props;
  return (
    <Section
      className={classes([
        'SectionEx',
        capitalize && 'SectionEx__capitalize',
        className,
        computeBoxClassName(rest),
      ])}
      {...rest} />
  );
};
