/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Button, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Image } from '../../components';
import type { ClothingBoothData } from './type';

interface PreviewImageProps {
  height: number;
  icon: string;
}

const PreviewImage = (props: PreviewImageProps) => {
  const DEFAULT_PREVIEW_HEIGHT = 64;
  const { height = DEFAULT_PREVIEW_HEIGHT, icon } = props;
  return (
    <Image height={`${height * 2}px`} src={`data:image/png;base64,${icon}`} />
  );
};

export const CharacterPreview = () => {
  const { act, data } = useBackend<ClothingBoothData>();
  const { previewHeight, previewIcon, previewShowClothing } = data;
  return (
    <Stack vertical align="center">
      <Stack.Item textAlign>
        <PreviewImage height={previewHeight} icon={previewIcon} />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="rotate-right"
          tooltip="Clockwise"
          tooltipPosition="bottom"
          onClick={() => act('rotate-cw')}
        />
        <Button
          icon="rotate-left"
          tooltip="Counter-clockwise"
          tooltipPosition="bottom"
          onClick={() => act('rotate-ccw')}
        />
      </Stack.Item>
      <Stack.Item>
        <Button.Checkbox
          checked={!previewShowClothing}
          color="transparent"
          onClick={() => act('toggle-clothing')}
        >
          Hide Clothing
        </Button.Checkbox>
      </Stack.Item>
    </Stack>
  );
};
