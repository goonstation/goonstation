/**
 * @file
 * @copyright 2026
 * @author Valtsu0 (https://github.com/Valtsu0)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { NormalCollection } from './normal';
import { SecretCollection } from './secret';
import type { FishCollectionData, FishData } from './type';
import { CollectionType } from './type';

export const FishCollection = (props) => {
  const { act, data } = useBackend<FishCollectionData>();

  const { fish_data, collected } = data;

  let normal_collection: FishData[] = Array();
  let secret_collection: FishData[] = Array();

  for (let i = 0; i < fish_data.length; i++) {
    switch (fish_data[i]?.collection) {
      case CollectionType.Normal:
        normal_collection.push(fish_data[i]);
        break;
      case CollectionType.Secret:
        if (collected?.includes(fish_data[i].name)) {
          secret_collection.push(fish_data[i]);
        }
        break;
    }
  }

  return (
    <Window title="Fish Collection" theme="ntos" width={472} height={390}>
      <Window.Content scrollable>
        <NormalCollection
          collected={collected}
          collection={normal_collection}
        />
        {!!secret_collection.length && (
          <SecretCollection collection={secret_collection} />
        )}
      </Window.Content>
    </Window>
  );
};
