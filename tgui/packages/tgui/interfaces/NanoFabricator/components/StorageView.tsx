/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import {
  Box,
  Button,
  Icon,
  Image,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../../backend';
import type { NanoFabricatorData, NanoStorageData } from '../type';

export const StorageView = (props: { storage: NanoStorageData[] }) => {
  const { act } = useBackend<NanoFabricatorData>();
  const { storage } = props;
  const sortedStorage = [...storage].sort((a, b) =>
    a.name.replace(/^\d+\s+/, '').localeCompare(b.name.replace(/^\d+\s+/, '')),
  );

  return (
    <Section fill scrollable title="Storage">
      {storage.length ? (
        <Stack vertical>
          {sortedStorage.map((item) => (
            <Stack.Item key={item.ref}>
              <Stack align="center">
                <Stack.Item>{item.img && <Image src={item.img} />}</Stack.Item>
                <Stack.Item grow overflow="hidden">
                  <Box
                    nowrap
                    overflow="hidden"
                    style={{ textOverflow: 'ellipsis' }}
                  >
                    {item.name}
                  </Box>
                  <Box color="label">{item.amount} available</Box>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    tooltip="Eject"
                    onClick={() => act('eject', { ref: item.ref })}
                  >
                    <Stack fill>
                      <Stack.Item>
                        <Icon name="eject" />
                      </Stack.Item>
                    </Stack>
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          ))}
        </Stack>
      ) : (
        <NoticeBox>No objects found in storage.</NoticeBox>
      )}
    </Section>
  );
};
