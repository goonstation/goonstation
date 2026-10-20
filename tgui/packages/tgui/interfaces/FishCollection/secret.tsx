/**
 * @file
 * @copyright 2026
 * @author Valtsu0 (https://github.com/Valtsu0)
 * @license MIT
 */

import { Divider, Image, Stack, Tooltip } from 'tgui-core/components';

export const SecretCollection = (props) => {
  const { collection } = props;

  return (
    <>
      Collected hidden fish: {collection?.length ?? 0}
      <Divider />
      <Stack wrap="wrap" justify="space-around">
        {collection.map((fish) => {
          return (
            <Stack.Item key={fish.name}>
              <Tooltip content={fish.name}>
                <Image src={`data:image/png;base64,${fish.image}`} />
              </Tooltip>
            </Stack.Item>
          );
        })}
      </Stack>
    </>
  );
};
