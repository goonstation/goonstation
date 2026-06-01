/**
 * @file
 * @copyright 2026
 * @author Valtsu0 (https://github.com/Valtsu0)
 * @license MIT
 */

import { Divider, Image, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface FishData {
  names: string[];
  images: string[];
  silhouettes: string[];
  collected: string[];
}

export const FishCollection = (props, context) => {
  const { act, data } = useBackend<FishData>();

  const { names, images, silhouettes, collected } = data;

  return (
    <Window title="Fish Collection" theme="ntos" width={420} height={320}>
      <Window.Content>
        Collected fish: {collected.length}/{images.length}
        <Divider />
        <Stack wrap="wrap" justify="space-around">
          {names.map((item, index) => (
            <Stack.Item key={item}>
              <Image
                src={`data:image/png;base64,${collected.includes(item) ? images[index] : silhouettes[index]}`}
              />
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
