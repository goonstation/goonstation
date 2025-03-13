/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license ISC
 */

import { Box, Button, Flex, Image, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const MixerItem = (props) => {
  const { act } = useBackend();

  const { mixerItem, working } = props;

  return (
    <Flex>
      <Image
        verticalAlign="middle"
        height="24px"
        width="24px"
        src={`data:image/png;base64,${mixerItem.iconData}`}
      />
      <Button
        nowrap
        icon="eject"
        color="blue"
        tooltip={`Eject ${mixerItem.name}`}
        textAlign="center"
        disabled={working}
        onClick={() => act('eject', { index: mixerItem.index })}
      />

      <Box
        nowrap
        as="span"
        key={mixerItem.index}
        m="0.25rem"
        textAlign="center"
      >
        {mixerItem.name}
      </Box>
    </Flex>
  );
};

interface MixerMachineData {
  maxItems;
  mixerContents;
  working;
}

export const MixerMachine = () => {
  const { data, act } = useBackend<MixerMachineData>();
  const items = data.mixerContents;
  return (
    <Window title="Kitchen Helper" width={500} height={220}>
      <Window.Content>
        <Stack m="0.25rem" vertical fill>
          <Stack.Item grow={1}>
            <Section
              fill
              title={`Contents: (${items.length}/${data.maxItems})`}
            >
              {items.length > 0
                ? items.map((item) => (
                    <MixerItem
                      key={item.index}
                      mixerItem={item}
                      working={data.working}
                    />
                  ))
                : 'No contents in mixer'}
            </Section>
          </Stack.Item>

          <Stack.Item m=".25rem">
            <Button
              mt="0.5rem"
              backgroundColor="green"
              icon="check"
              tooltip="Start Mixing"
              textAlign="center"
              disabled={data.working || items.length === 0}
              onClick={() => act('mix', {})}
            >
              Mix
            </Button>

            <Button
              backgroundColor="blue"
              icon="eject"
              tooltip="Eject All"
              textAlign="center"
              disabled={data.working || items.length === 0}
              onClick={() => act('ejectAll', {})}
            >
              Eject All
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
