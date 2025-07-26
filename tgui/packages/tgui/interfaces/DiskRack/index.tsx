import { Box, Button, Divider, Flex, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Led } from './LED';
import { Disk, DiskButtonProps, DiskRackData } from './types';

const DiskButton = (props: DiskButtonProps) => {
  const { index, ...rest } = props;
  const { act } = useBackend();
  return (
    <Button
      width="25em"
      {...rest}
      key={props.index}
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
                        icon="eject"
                        iconPosition="left"
                        index={disks.length - index - 1}
                        backgroundColor={disk.color}
                        textColor="black"
                        tooltip={disk.name}
                        style={{
                          cursor: 'grab',
                        }}
                      >
                        <Box
                          width="21em"
                          inline
                          backgroundColor="white"
                          pt="3px"
                          pl="4px"
                          height="25px"
                          mb="-3px"
                          bold
                          style={{
                            borderColor: '#cccccc',
                            borderWidth: '3px',
                            borderStyle: 'ridge',
                            borderTop: 'none',
                            borderRadius: '10px',
                            borderTopLeftRadius: '0px',
                            borderTopRightRadius: '0px',
                            overflow: 'hidden',
                            textOverflow: 'ellipsis',
                          }}
                        >
                          {disk.name}
                        </Box>
                      </DiskButton>
                    ) : (
                      <DiskButton index={disks.length - index - 1}>
                        <Box inline height="27px" pt="3px" pl="28px">
                          Empty slot
                        </Box>
                      </DiskButton>
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
