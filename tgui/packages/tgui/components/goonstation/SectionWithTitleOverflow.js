import { classes } from 'common/react';
import { computeBoxClassName, computeBoxProps } from '../Box';
import { Section } from '../Section';

export const SectionWithTitleOverflow = props => {
  const {
    className,
    ...rest
  } = props;
  return (
    <Section
      className={classes([
        'SectionWithTitleOverflow',
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)} />
  );
};
