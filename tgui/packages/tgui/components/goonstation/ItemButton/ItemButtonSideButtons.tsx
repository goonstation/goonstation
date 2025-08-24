/**
 * @file
 * @copyright 2025
 * @author Garash (https://github.com/garash2k)
 * @license MIT
 */

import { Button, Icon, Stack } from 'tgui-core/components';

import { ItemButtonProps, SideButtonProps } from '.';
import { ItemButtonMiniButtonStyle, ItemButtonStyle } from './style';

type ItemButtonSideButtonsProps = Pick<
  ItemButtonProps,
  'sideButton1' | 'sideButton2'
>;
export const ItemButtonSideButtons = (props: ItemButtonSideButtonsProps) => {
  const { sideButton1, sideButton2 } = props;

  return (
    <Stack.Item mx={ItemButtonStyle.MarginX} my={ItemButtonStyle.MarginY}>
      {sideButton1 && <ItemButtonSideButton sideButton={sideButton1} />}
      {sideButton2 && <ItemButtonSideButton sideButton={sideButton2} />}
    </Stack.Item>
  );
};

interface ItemButtonSideButtonProps {
  sideButton: SideButtonProps;
}
const ItemButtonSideButton = (props: ItemButtonSideButtonProps) => {
  const { sideButton } = props;
  const { icon, tooltip, color, disabled, onClick } = sideButton;
  return (
    <Button
      width={ItemButtonMiniButtonStyle.Width}
      height={
        ItemButtonStyle.Height / 2 - ItemButtonMiniButtonStyle.Spacing / 4
      }
      py={ItemButtonMiniButtonStyle.IconSize / 2}
      align="center"
      style={{ display: 'block' }}
      onClick={onClick}
      color={color}
      disabled={disabled}
      tooltip={tooltip}
    >
      <Icon name={icon} />
    </Button>
  );
};
