/**
 * @file
 * @copyright 2024
 * @author cringe (https://github.com/Laboredih123)
 * @license MIT
 */

import {
  Box,
  Button,
  Flex,
  Image,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

interface HandPipeDispenserData {
  fluidpipes;
  fluidmachines;
  selectedimage;
}

const Tab = {
  FluidPipes: 'fluidpipes',
  FluidMachines: 'fluidmachines',
};

export const HandPipeDispenser = () => {
  const { data } = useBackend<HandPipeDispenserData>();
  const { fluidpipes, fluidmachines, selectedimage } = data;
  const [tab, setTab] = useSharedState('tab', Tab.FluidPipes);
  return (
    <Window width={400} height={350}>
      <Flex height="100%">
        <Flex.Item fill>
          <Section fill>
            <Button color="green">Create</Button>
            <br />
            <Button color="red">Remove</Button>
            <br />
            <Box
              style={{
                border: '1px solid grey',
              }}
            >
              <Image
                style={{ width: 64, height: 64 }}
                src={`data:image/png;base64,${selectedimage}`}
              />
            </Box>
          </Section>
        </Flex.Item>
        <Flex.Item position="relative" ml={1} grow fill>
          <Window.Content scrollable>
            <Section>
              <Tabs fluid>
                <Tabs.Tab
                  selected={tab === Tab.FluidPipes}
                  onClick={() => setTab(Tab.FluidPipes)}
                >
                  Pipes
                </Tabs.Tab>
                <Tabs.Tab
                  selected={tab === Tab.FluidMachines}
                  onClick={() => setTab(Tab.FluidMachines)}
                >
                  Machines
                </Tabs.Tab>
              </Tabs>
              {tab === Tab.FluidPipes && (
                <Section>
                  {fluidpipes.map((fluidpipe) => {
                    return <ItemRow key={fluidpipe} item={fluidpipe} />;
                  })}
                </Section>
              )}
              {tab === Tab.FluidMachines && (
                <Section>
                  {fluidmachines.map((fluidmachine) => {
                    return <ItemRow key={fluidmachine} item={fluidmachine} />;
                  })}
                </Section>
              )}
            </Section>
          </Window.Content>
        </Flex.Item>
      </Flex>
    </Window>
  );
};

export const ItemRow = (props) => {
  const { act } = useBackend();
  const { item } = props;

  return (
    <Stack style={{ borderBottom: '1px #555 solid' }}>
      {item.image && (
        <Stack.Item>
          <Box style={{ overflow: 'show', height: '32px' }}>
            <Image src={`data:image/png;base64,${item.image}`} />
          </Box>
        </Stack.Item>
      )}
      <Stack.Item grow>{item.type}</Stack.Item>
      <Stack.Item
        style={{
          marginLeft: '5px',
          display: 'flex',
          justifyContent: 'center',
          flexDirection: 'column',
        }}
      >
        <Button
          color="green"
          textAlign="center"
          width="70px"
          onClick={() =>
            act('select', {
              type: item.type,
            })
          }
        >
          Select
        </Button>
      </Stack.Item>
    </Stack>
  );
};
