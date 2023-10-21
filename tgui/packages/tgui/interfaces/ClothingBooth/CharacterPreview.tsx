import { useBackend } from '../../backend';
import { Button, Image, Stack } from '../../components';
import type { ClothingBoothData } from './type';

export const CharacterPreview = (_, context) => {
  const { act, data } = useBackend<ClothingBoothData>(context);
  return (
    <Stack vertical align="center">
      <Stack.Item textAlign>
        <Image height={data.previewHeight * 2 + 'px'} pixelated src={`data:image/png;base64,${data.previewIcon}`} />
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
