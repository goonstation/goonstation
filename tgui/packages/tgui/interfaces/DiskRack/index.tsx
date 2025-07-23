import { hexToHsva } from 'common/goonstation/colorful';
import { BooleanLike } from 'common/react';
import { Button, Divider, Flex, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ButtonProps } from '../../components/Button';
import { Window } from '../../layouts';
import { Led } from './LED';

interface DiskRackData {
  disks: Disk[];
  has_lights: BooleanLike;
}

interface Disk {
  name: string;
  color: string;
  light: BooleanLike;
}

type DiskButtonProps = Partial<{
  index: number;
}> &
  ButtonProps;

const DiskButton = (props: DiskButtonProps) => {
  const { index, ...rest } = props;
  const { act } = useBackend();
  return (
    <Button
      width="15em"
      textAlign="center"
      key={props.index}
      {...rest}
      onClick={() => act('action', { id: index ? index + 1 : 1 })}
    />
  );
};

export const DiskRack = (_props: unknown) => {
  const { data } = useBackend<DiskRackData>();
  const { disks } = data;
  return (
    <Window
      title="Disk Rack"
      height={disks.length * 45}
      width={200 + (data.has_lights ? 24 : 0)}
    >
      <Window.Content>
        <Divider />
        <Stack vertical>
          {disks.reverse().map((disk: Disk, index) => (
            <Stack.Item key={index}>
              <Flex>
                <Flex.Item>
                  {disk ? (
                    <DiskButton
                      index={disks.length - index - 1}
                      backgroundColor={disk.color}
                      textColor={
                        hexToHsva(disk.color).v > 50 ? 'black' : 'white'
                      }
                    >
                      {disk.name}
                    </DiskButton>
                  ) : (
                    <DiskButton index={disks.length - index - 1}>
                      Empty slot
                    </DiskButton>
                  )}
                </Flex.Item>
                {!!data.has_lights && (
                  <Flex.Item>
                    <Led flashing={disk?.light} />
                  </Flex.Item>
                )}
              </Flex>
              <Divider />
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
