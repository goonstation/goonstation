/**
 * @file
 * @copyright 2026
 * @author Valtsu0 (https://github.com/Valtsu0)
 * @license MIT
 */

import { Divider, Image, Stack, Tooltip } from 'tgui-core/components';

export const NormalCollection = (props) => {
  const { collected, collection } = props;

  return (
    <>
      Collected fish: {collected?.length ?? 0}/{collection.length}
      <Divider />
      <Stack wrap="wrap" justify="space-around">
        {collection.map((fish) => {
          const isCollected = collected?.includes(fish.name) ?? false;
          return (
            <Stack.Item key={fish.name}>
              <Tooltip content={isCollected ? fish.name : '???'}>
                <Image
                  src={`data:image/png;base64,${isCollected ? fish.image : fish.silhouette}`}
                />
              </Tooltip>
            </Stack.Item>
          );
        })}
      </Stack>
      <br />
    </>
  );
};
