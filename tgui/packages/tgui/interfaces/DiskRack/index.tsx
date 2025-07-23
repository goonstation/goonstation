import { hexToHsva } from 'common/goonstation/colorful';
import { Button, Divider, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ButtonProps } from '../../components/Button';
import { Window } from '../../layouts';

interface DiskRackData {
  disks: Disk[];
}

interface Disk {
  name: string;
  color: string;
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
    <Window height={disks.length * 50} width={300}>
      <Window.Content>
        <Divider />
        <Stack vertical>
          {disks.reverse().map((disk: Disk, index) => (
            <Stack.Item key={index}>
              {disk ? (
                <DiskButton
                  index={disks.length - index - 1}
                  backgroundColor={disk.color}
                  textColor={hexToHsva(disk.color).v > 50 ? 'black' : 'white'}
                >
                  {disk.name}
                </DiskButton>
              ) : (
                <DiskButton index={disks.length - index - 1}>
                  Empty slot
                </DiskButton>
              )}
              <Divider />
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
