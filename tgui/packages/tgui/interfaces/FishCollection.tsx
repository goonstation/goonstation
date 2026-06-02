/**
 * @file
 * @copyright 2026
 * @author Valtsu0 (https://github.com/Valtsu0)
 * @license MIT
 */

import { Divider, Image, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface FishCollectionData {
  fish_data: FishData[];
  collected: string[];
}

interface FishData {
  name: string;
  image: string;
  silhouette: string;
}

export const FishCollection = (props, context) => {
  const { act, data } = useBackend<FishCollectionData>();

  const { fish_data, collected } = data;

  return (
    <Window title="Fish Collection" theme="ntos" width={420} height={320}>
      <Window.Content>
        Collected fish: {collected ? collected.length : 0}/{fish_data.length}
        <Divider />
        <Stack wrap="wrap" justify="space-around">
          {fish_data.map((fish) => (
            <Stack.Item key={fish.name}>
              <Image
                src={`data:image/png;base64,${(collected ? collected.includes(fish.name) : false) ? fish.image : fish.silhouette}`}
              />
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
