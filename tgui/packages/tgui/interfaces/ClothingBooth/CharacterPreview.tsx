import { useBackend } from '../../backend';
import { Button, Image, Stack } from '../../components';
import type { ClothingBoothData } from './type';

interface PreviewImageProps {
  height: number;
  icon64: string;
}

const PreviewImage = (props: PreviewImageProps) => {
  const { height, icon64 } = props;
  return <Image height={`${height * 2}px`} pixelated src={`data:image/png;base64,${icon64}`} />;
};

export const CharacterPreview = (_, context) => {
  const { act, data } = useBackend<ClothingBoothData>(context);
  const { previewHeight, previewIcon64, previewShowClothing } = data;
  return (
    <Stack vertical align="center">
      <Stack.Item textAlign>
        <PreviewImage height={previewHeight} icon64={previewIcon64} />
      </Stack.Item>
      <Stack.Item>
        <Button icon="rotate-right" tooltip="Clockwise" tooltipPosition="bottom" onClick={() => act('rotate-cw')} />
        <Button
          icon="rotate-left"
          tooltip="Counter-clockwise"
          tooltipPosition="bottom"
          onClick={() => act('rotate-ccw')}
        />
      </Stack.Item>
      <Stack.Item>
        <Button.Checkbox checked={!previewShowClothing} color="transparent" onClick={() => act('toggle-clothing')}>
          Hide Clothing
        </Button.Checkbox>
      </Stack.Item>
    </Stack>
  );
};
