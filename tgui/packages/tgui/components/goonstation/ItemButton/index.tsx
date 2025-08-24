/**
 * @file
 * @copyright 2025
 * @author Garash (https://github.com/garash2k)
 * @license MIT
 */

import { Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { ItemButtonMainButton } from './ItemButtonMainButton';
import { ItemButtonSideButtons } from './ItemButtonSideButtons';

export interface ItemButtonProps {
  image?: string | null;
  name: string;
  disabled?: boolean;
  tooltip?: string;

  sideButton1?: SideButtonProps;
  sideButton2?: SideButtonProps;

  onMainButtonClick: () => void;
}

export interface SideButtonProps {
  icon: string;
  tooltip?: any;
  color?: string;
  disabled: BooleanLike;

  onClick?: () => void;
}

export const ItemButton = (props: ItemButtonProps) => {
  const {
    image,
    name,
    disabled,
    tooltip,
    sideButton1,
    sideButton2,
    onMainButtonClick,
  } = props;

  return (
    <Stack style={{ display: 'inline-flex' }}>
      <ItemButtonMainButton
        image={image}
        name={name}
        disabled={disabled}
        tooltip={tooltip}
        onMainButtonClick={onMainButtonClick}
      />
      <ItemButtonSideButtons
        sideButton1={sideButton1}
        sideButton2={sideButton2}
      />
    </Stack>
  );
};
