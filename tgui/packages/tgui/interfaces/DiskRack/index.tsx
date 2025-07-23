import { Button, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ButtonProps } from '../../components/Button';
import { Window } from '../../layouts';

interface DiskRackData {
  disks: string[];
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
      width="10em"
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
    <Window height={disks.length * 10}>
      <Window.Content>
        <Stack vertical>
          {disks.map((string, index) => (
            <Stack.Item key={index}>
              {string ? (
                <DiskButton id={index}>{string}</DiskButton>
              ) : (
                <DiskButton id={index} disabled>
                  Empty slot
                </DiskButton>
              )}
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
