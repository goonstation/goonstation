import { classes } from 'common/react';
import { ComponentProps } from 'react';
import { Button } from 'tgui-core/components';

type ColorCheckboxProps = Partial<{
  selectedColor: string;
  disabledColor: string;
}> &
  ComponentProps<typeof Button.Checkbox>;

export const ColorCheckbox = (props: ColorCheckboxProps) => {
  const { selectedColor, disabledColor, ...rest } = props;
  return (
    <Button.Checkbox
      className={classes([
        'ColorCheckbox',
        selectedColor && `ColorCheckbox--selectedColor--${selectedColor}`,
        disabledColor && `ColorCheckbox--disabledColor--${disabledColor}`,
      ])}
      {...rest}
    />
  );
};
