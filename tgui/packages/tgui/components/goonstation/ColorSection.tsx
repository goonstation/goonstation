import { classes } from 'common/react';
import { ComponentProps } from 'react';
import { Section } from 'tgui-core/components';

export const ColorSection = (props: ComponentProps<typeof Section>) => {
  const { color, children, ...rest } = props;
  return (
    <Section
      className={classes([
        'ColorSection',
        color && `ColorSection--color--${color}`,
      ])}
      {...rest}
    >
      {children}
    </Section>
  );
};
