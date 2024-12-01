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
  atmospipes;
  atmosmachines;
  selectedimage;
}

const Tab = {
  AtmosPipes: 'atmospipes',
  AtmosMachines: 'atmosmachines',
};

export const HandPipeDispenser = () => {
  const { data } = useBackend<HandPipeDispenserData>();
  const { atmospipes, atmosmachines, selectedimage } = data;
  const [tab, setTab] = useSharedState('tab', Tab.AtmosPipes);
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
                  selected={tab === Tab.AtmosPipes}
                  onClick={() => setTab(Tab.AtmosPipes)}
                >
                  Pipes
                </Tabs.Tab>
                <Tabs.Tab
                  selected={tab === Tab.AtmosMachines}
                  onClick={() => setTab(Tab.AtmosMachines)}
                >
                  Machines
                </Tabs.Tab>
              </Tabs>
              {tab === Tab.AtmosPipes && (
                <Section>
                  {atmospipes.map((atmospipe) => {
                    return <ItemRow key={atmospipe} item={atmospipe} />;
                  })}
                </Section>
              )}
              {tab === Tab.AtmosMachines && (
                <Section>
                  {atmosmachines.map((atmosmachine) => {
                    return <ItemRow key={atmosmachine} item={atmosmachine} />;
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
