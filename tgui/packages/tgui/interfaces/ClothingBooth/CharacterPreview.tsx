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
  const { previewHeight, previewIcon } = data;
  return (
    <Stack vertical align="center">
      <Stack.Item>
        <PreviewImage height={previewHeight} icon64={previewIcon} />
      </Stack.Item>
      <Stack.Item>
        <Button icon="chevron-left" tooltip="Clockwise" tooltipPosition="right" onClick={() => act('rotate-cw')} />
        <Button
          icon="chevron-right"
          tooltip="Counter-clockwise"
          tooltipPosition="right"
          onClick={() => act('rotate-ccw')}
        />
      </Stack.Item>
    </Stack>
  );
};
