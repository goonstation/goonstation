/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Box, Button, Flex, Section } from '../components';
import { Window } from '../layouts';

export const MixerItem = (props, context) => {
  const { act } = useBackend(context);

  const { mixerItem, working } = props;

  return (
    <Flex>
      <Flex.Item nowrap key={mixerItem.name}>
        <Button
          nowrap
          icon="eject"
          color="blue"
          title={"Eject " + mixerItem.name}
          textAlign="center"
          disabled={working}
          onClick={() => act("eject", { index: mixerItem.index })} />

        <Box nowrap
          as="span"
          key={mixerItem.index}
          m="0.25rem"
          textAlign="center">
          {mixerItem.name}
        </Box>
      </Flex.Item>
    </Flex>
  );
};

export const MixerMachine = (props, context) => {
  const { data, act } = useBackend(context);
  console.log(data);

  const items = data.mixerContents;
  return (
    <Window
      title="Kitchen Helper"
      width={500}
      height={275}
      theme="ntos">
      <Window.Content >
        <Flex wrap m="0.25rem" fontSize="1.4rem">
          <Box minWidth="100%">
            {
              <Section title={"Contents: (" + items.length + "/" + data.maxItems + ")"}>
                {
                  (items.length > 0)
                    ? items.map(item => (<MixerItem key={item.index} mixerItem={item} working={data.working} />))
                    :"No contents in mixer"
                }
              </Section>
            }
          </Box>
          <Button
            minWidth="48%"
            backgroundColor="green"
            icon="check"
            title={"Start Mixing"}
            textAlign="center"
            disabled={data.working || items.length === 0}
            onClick={() => act("mix", {})}>Mix
          </Button>

          <Button
            minWidth="48%"
            backgroundColor="blue"
            icon="eject"
            title={"Eject All"}
            textAlign="center"
            disabled={data.working || items.length === 0}
            onClick={() => act("ejectAll", {})}>Eject All
          </Button>

        </Flex>
      </Window.Content>
    </Window>
  );
};
