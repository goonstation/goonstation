/**
 * @file
 * @copyright 2024
 * @author cringe (https://github.com/Laboredih123)
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
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

import { useBackend, useSharedState } from '../../backend';
import { Icon } from '../../components';
import { Window } from '../../layouts';
import { ByondDir, HandPipeDispenserData, PipeData, Tab } from './type';

export const HandPipeDispenser = () => {
  const { act, data } = useBackend<HandPipeDispenserData>();
  const {
    atmospipes,
    atmosmachines,
    selectedimage,
    selectedcost,
    resources,
    selecteddesc,
  } = data;
  const [tab, setTab] = useSharedState('tab', Tab.AtmosPipes);
  return (
    <Window width={450} height={350}>
      <Flex height="100%">
        <Flex.Item fill>
          <Section
            fill
            title={
              <>
                Resources: {resources} <Icon name="boxes-stacked" />
              </>
            }
          >
            {/* Stack hell zone aka the preview with buttons */}
            <Stack vertical>
              <Box position="absolute" right="7px">
                {selectedcost} <Icon name="boxes-stacked" />
              </Box>
              <Stack.Item>
                <Box textAlign="center">
                  <Button
                    icon="arrow-up"
                    onClick={() => act('changedir', { newdir: ByondDir.North })}
                  />
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Flex align="center" justify="space-around">
                  <Flex.Item>
                    <Button
                      icon="arrow-left"
                      onClick={() =>
                        act('changedir', { newdir: ByondDir.West })
                      }
                    />
                  </Flex.Item>
                  <Flex.Item>
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
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      icon="arrow-right"
                      onClick={() =>
                        act('changedir', { newdir: ByondDir.East })
                      }
                    />
                  </Flex.Item>
                </Flex>
              </Stack.Item>
              <Stack.Item>
                <Box textAlign="center">
                  <Button
                    icon="arrow-down"
                    onClick={() => act('changedir', { newdir: ByondDir.South })}
                  />
                </Box>
              </Stack.Item>
              <Stack.Item>
                {/* Mode switch button */}
                {!!data.destroying && (
                  <Button
                    textAlign="center"
                    width="100%"
                    color="red"
                    icon="xmark"
                    onClick={() => act('toggle-destroying')}
                  >
                    Removing
                  </Button>
                )}
                {!data.destroying && (
                  <Button
                    textAlign="center"
                    width="100%"
                    color="green"
                    icon="plus"
                    onClick={() => act('toggle-destroying')}
                  >
                    Placing
                  </Button>
                )}
              </Stack.Item>
              <Stack.Item width="13em">
                <Box
                  style={{
                    border: '1px solid grey',
                    padding: '2px',
                  }}
                >
                  {selecteddesc}
                </Box>
              </Stack.Item>
            </Stack>
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
                  {atmospipes.map((atmospipe: PipeData) => {
                    return <ItemRow {...atmospipe} key={atmospipe.name} />;
                  })}
                </Section>
              )}
              {tab === Tab.AtmosMachines && (
                <Section>
                  {atmosmachines.map((atmosmachine: PipeData) => {
                    return (
                      <ItemRow key={atmosmachine.name} {...atmosmachine} />
                    );
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

export const ItemRow = (item: PipeData) => {
  const { act } = useBackend();

  return (
    <Stack style={{ borderBottom: '1px #555 solid' }}>
      {item.image && (
        <Stack.Item>
          <Box style={{ overflow: 'show', height: '32px' }}>
            <Image src={`data:image/png;base64,${item.image}`} />
          </Box>
        </Stack.Item>
      )}
      <Stack.Item grow>
        {item.name}
        <br />
        {item.cost} <Icon name="boxes-stacked" />
      </Stack.Item>
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
              name: item.name,
            })
          }
        >
          Select
        </Button>
      </Stack.Item>
    </Stack>
  );
};
