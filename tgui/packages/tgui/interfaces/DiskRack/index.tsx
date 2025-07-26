import { Divider, Flex, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { DiskButton } from './DiskButton';
import { Led } from './LED';
import { Disk, DiskRackData } from './types';

export const DiskRack = (_props: unknown) => {
  const { data, act } = useBackend<DiskRackData>();
  const { disks } = data;
  return (
    <Window
      title="Disk Rack"
      height={disks.length * 46 + 5}
      width={315 + (data.has_lights ? 25 : 0)}
    >
      <Window.Content>
        <Divider />
        <Stack vertical>
          {disks.reverse().map((disk: Disk, index) => (
            <>
              <Stack.Item key={index}>
                <Flex>
                  <Flex.Item>
                    {disk ? (
                      <DiskButton
                        index={disks.length - index - 1}
                        diskName={disk.name}
                        diskColor={disk.color}
                      />
                    ) : (
                      <DiskButton index={disks.length - index - 1} />
                    )}
                  </Flex.Item>
                  {!!data.has_lights && (
                    <Flex.Item>
                      <Led flashing={disk?.light} />
                    </Flex.Item>
                  )}
                </Flex>
              </Stack.Item>
              <Stack.Divider />
            </>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
