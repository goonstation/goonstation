/**
 * @file
 * @copyright 2025
 * @author Garash (https://github.com/garash2k)
 * @license MIT
 */

import { Button, Image, Stack } from 'tgui-core/components';

import { ItemButtonProps } from '.';
import { ItemButtonStyle } from './style';

type ItemButtonMainButtonProps = Pick<
  ItemButtonProps,
  'image' | 'name' | 'disabled' | 'tooltip' | 'onMainButtonClick'
>;

export const ItemButtonMainButton = (props: ItemButtonMainButtonProps) => {
  const { image, name, disabled, tooltip, onMainButtonClick } = props;

  return (
    <Stack.Item ml={ItemButtonStyle.MarginX} my={ItemButtonStyle.MarginY}>
      <Button
        width={ItemButtonStyle.Width}
        height={ItemButtonStyle.Height}
        px={0}
        className="Button--ComplexContent"
        onClick={onMainButtonClick}
        disabled={disabled}
        tooltip={tooltip}
      >
        <Stack height="100%">
          <Stack.Item basis="60px">
            {image && (
              <Image
                src={image}
                backgroundColor="rgba(0,0,0,0.2)"
                height="100%"
              />
            )}
          </Stack.Item>
          <Stack.Item grow mx={1} align="center">
            {name}
          </Stack.Item>
        </Stack>
      </Button>
    </Stack.Item>
  );
};
